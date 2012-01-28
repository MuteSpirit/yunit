//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// mine.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
    We use "wide" variant (with suffix W in name, i.e. CreateEventW) of WinAPI functions instead of 
    "ansi" variants, i.e. CreateEventA, because "ansi" variants are only wrapper over "wide" variants
*/

#define YUNIT_DLL_EXPORTS
#include "yunit.h"
#include "mine.h"
#include "lua_wrapper.h"


#ifdef _WIN32
#define UNICODE
#include <process.h>
#include <windows.h>
#else
#include <unistd.h>
#include <pthread.h>
#endif

namespace YUNIT_NS {

class UndefinedApiBehaviour 
{
};
 
#ifdef _WIN32
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define MineImplWin32 MineImpl

class MineImplWin32
{
public:
    MineImplWin32(DamageAgent* damageAgent);
    ~MineImplWin32();

    void setTimer(Seconds seconds);
    void neutralize();

    static void mineThread(void* param);

private:
    DamageAgent* damageAgent_;
    HANDLE thread_;
    unsigned long timeToBoom_;
    HANDLE orderReceivedEvent_;
};

#else 

#define MineImplPthreads MineImpl

class MineImplPthreads
{
public:
    MineImplPthreads(DamageAgent* damageAgent);
    ~MineImplPthreads();

    void setTimer(Seconds seconds);
    void neutralize();

    static void* mineThread(void* param);

private:
    DamageAgent* damageAgent_;
    pthread_t thread_;
    unsigned long timeToBoom_;
    pthread_mutex_t orderReceived_;
    pthread_cond_t orderReceivedCv_;
};

#endif // #ifdef _WIN32

class ProcessKiller : public DamageAgent
{
public:
    void boom() { abort(); }
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Seconds::Seconds(unsigned long num)
: num_(num)
{
}

void sleep(Seconds seconds)
{
#if defined(_WIN32)
    ::Sleep(1000 * seconds.num_);
#else
    ::sleep(seconds.num_);
#endif
}

#ifdef _WIN32
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void MineImplWin32::mineThread(void* param)
{
    MineImplWin32* mineImpl = reinterpret_cast<MineImplWin32*>(param);

    for (;;) // not use while(1) to avoid compiler warning "expression is constant"
    {
        int waitRes = ::WaitForSingleObject(mineImpl->orderReceivedEvent_, mineImpl->timeToBoom_);

        if (WAIT_TIMEOUT == waitRes)
            break;
        else if (WAIT_FAILED == waitRes || WAIT_ABANDONED == waitRes)
            throw UndefinedWinApiBehaviour();
    }

    mineImpl->damageAgent_->boom();
}

MineImplWin32::MineImplWin32(DamageAgent* damageAgent)
: damageAgent_(damageAgent)
, thread_(INVALID_HANDLE_VALUE)
, orderReceivedEvent_(::CreateEvent(0, FALSE, FALSE, 0))
, timeToBoom_(INFINITE)
{
    thread_ = reinterpret_cast<HANDLE>(_beginthread(mineThread, 0, this));
    if (0 == thread_)
        throw UndefinedWinApiBehaviour();
}

MineImplWin32::~MineImplWin32()
{
    timeToBoom_ = 0;
    ::SetEvent(orderReceivedEvent_);
    ::CloseHandle(thread_);
}

void MineImplWin32::setTimer(Seconds seconds)
{
    if (INFINITE == timeToBoom_)
    {
        timeToBoom_ = seconds.num_;
        ::SetEvent(orderReceivedEvent_);
    }
}

void MineImplWin32::neutralize()
{
    if (INFINITE != timeToBoom_)
    {
        timeToBoom_ = INFINITE;
        ::SetEvent(orderReceivedEvent_);
    }
}

#else

MineImplPthreads::MineImplPthreads(DamageAgent* damageAgent)
: damageAgent_(damageAgent)
, timeToBoom_(-1)
{
    pthread_mutex_init(&orderReceived_, NULL);
    pthread_cond_init(&orderReceivedCv_, NULL);
  
    if (pthread_create(&thread_, NULL, mineThread, this))
        throw UndefinedApiBehaviour();
}

MineImplPthreads::~MineImplPthreads()
{
    pthread_mutex_destroy(&orderReceived_);
    pthread_cond_destroy(&orderReceivedCv_);
}

void MineImplPthreads::setTimer(Seconds seconds)
{
    pthread_mutex_lock(&orderReceived_);
    timeToBoom_ = seconds.num_;
    pthread_cond_signal(&orderReceivedCv_);
    pthread_mutex_unlock(&orderReceived_);
}

void MineImplPthreads::neutralize()
{
    pthread_mutex_lock(&orderReceived_);
    if (-1 != timeToBoom_)
    {
        timeToBoom_ = -1;
        pthread_cond_signal(&orderReceivedCv_);
    }
    pthread_mutex_unlock(&orderReceived_);
}

void* MineImplPthreads::mineThread(void* param)
{
    MineImpl* mineImpl = reinterpret_cast<MineImpl*>(param);
    timespec abstime;
    int rc;
    
    pthread_mutex_lock(&mineImpl->orderReceived_);
    for (;;) // not use while(1) to avoid compiler warning "expression is constant"
    {
        if (-1 == mineImpl->timeToBoom_)
        {
            // infinitely wait order
            rc = pthread_cond_wait(&mineImpl->orderReceivedCv_, &mineImpl->orderReceived_);
        }
        else
        {
            abstime.tv_sec = time(NULL) + mineImpl->timeToBoom_;
            abstime.tv_nsec = 0;
            rc = pthread_cond_timedwait(&mineImpl->orderReceivedCv_, &mineImpl->orderReceived_, &abstime);
            if (ETIMEDOUT == rc)
                break;
            else if (rc)
                throw UndefinedApiBehaviour();
        }
    }
    pthread_mutex_unlock(&mineImpl->orderReceived_);

    mineImpl->damageAgent_->boom();
    pthread_exit(NULL);
}

#endif // #ifdef _WIN32

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Mine::Mine(DamageAgent* damageAgent)
: impl_(new MineImpl(damageAgent))
{
}

Mine::~Mine()
{
    delete impl_;
}

void Mine::setTimer(Seconds seconds)
{
    impl_->setTimer(seconds);
}

void Mine::neutralize()
{
    impl_->neutralize();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
static ProcessKiller processKiller;
static Mine mine(&processKiller);

extern "C"
int YUNIT_API luaopen_yunit_mine(lua_State* L)
{
    Lua::State lua(L);
    luaWrapper<Mine>().regLib(lua, "yunit.mine");
    return 1;
}

LUA_META_METHOD(Mine, sleep)
{
    Lua::State lua(L);

    enum Args {timeoutInSecIdx = 1};

    if (!lua.isinteger(timeoutInSecIdx))
        lua.error("integer expected as argument, but was %s", lua.typeName(timeoutInSecIdx));

    sleep(Seconds(lua_tointeger(lua, timeoutInSecIdx)));
    return 0;
}

LUA_META_METHOD(Mine, setTimer)
{
    Lua::State lua(L);

    enum Args {timeoutInSecIdx = 1};

    if (!lua.isinteger(timeoutInSecIdx))
        lua.error("integer expected as argument, but was %s", lua.typeName(timeoutInSecIdx));

    mine.setTimer(Seconds(lua_tointeger(lua, timeoutInSecIdx)));
    return 0;
}

LUA_META_METHOD(Mine, turnoff)
{
    mine.neutralize();
    return 0;
}

} // namespace YUNIT_NS
