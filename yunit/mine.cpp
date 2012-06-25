//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// mine.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
    We use "wide" variant (with suffix W in name, i.e. CreateEventW) of WinAPI functions instead of 
    "ansi" variants, i.e. CreateEventA, because "ansi" variants are only wrapper over "wide" variants
*/

#define YUNIT_DLL_EXPORTS
#include "mine.h"
#include "lua_wrapper.h"


#ifdef _WIN32
//#  define UNICODE /// @todo Restore define and add wchar_t -> char convertion
#  include <process.h>
#  include <windows.h>
#else
#  include <unistd.h>
#  include <pthread.h>
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
    void turnoff();

    static unsigned int __stdcall mineThread(void* param);

private:
    DamageAgent* damageAgent_;
    HANDLE thread_;
    unsigned long timeToBoomInSec_;
    HANDLE orderReceivedEvent_;
    HANDLE stopMineThreadEvent_;
};

#else 

#define MineImplPthreads MineImpl

class MineImplPthreads
{
public:
    MineImplPthreads(DamageAgent* damageAgent);
    ~MineImplPthreads();

    void setTimer(Seconds seconds);
    void turnoff();

    static void* mineThread(void* param);

private:
    DamageAgent* damageAgent_;
    pthread_t thread_;
    unsigned long timeToBoomInSec_;
    pthread_mutex_t orderReceived_;
    pthread_cond_t orderReceivedCv_;
};

#endif // #ifdef _WIN32

class ProcessKiller : public DamageAgent
{
public:
    void boom() { abort(); } /// @todo Replace abort() with something else, because abort ignore UnhandleExceptionFilter function
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
unsigned int __stdcall MineImplWin32::mineThread(void* param)
{
    MineImpl* mineImpl = reinterpret_cast<MineImpl*>(param);
    
    enum {numOfEvents = 2};
    enum {stopEventIdx = 0, orderEventIdx = 1};
    HANDLE events[numOfEvents] = {mineImpl->stopMineThreadEvent_, mineImpl->orderReceivedEvent_};

    int timeout;
    for (;;) // not use while(1) to avoid compiler warning "expression is constant"
    {
        timeout = (INFINITE == mineImpl->timeToBoomInSec_) ? INFINITE : 1000 * mineImpl->timeToBoomInSec_;
        
        int waitRes = ::WaitForMultipleObjects(numOfEvents, events, FALSE, timeout);

        if (WAIT_OBJECT_0 + stopEventIdx == waitRes)
            break;
        if (WAIT_OBJECT_0 + orderEventIdx == waitRes)
            continue; // timeToBoomInSec_ has been changed, start to wait again
        else if (WAIT_TIMEOUT == waitRes)
        {
            mineImpl->damageAgent_->boom(); // as normal this action must kill current process
            break;
        }
        else if (WAIT_FAILED == waitRes || WAIT_ABANDONED == waitRes)
            throw UndefinedApiBehaviour();
    }

    return 0;
}

MineImplWin32::MineImplWin32(DamageAgent* damageAgent)
: damageAgent_(damageAgent)
, thread_(INVALID_HANDLE_VALUE)
, orderReceivedEvent_(::CreateEvent(0, FALSE, FALSE, 0))
, stopMineThreadEvent_(::CreateEvent(0, FALSE, FALSE, 0))
, timeToBoomInSec_(INFINITE)
{
    thread_ = reinterpret_cast<HANDLE>(_beginthreadex(NULL, 0, mineThread, this, 0, NULL));
    if (0 == thread_)
        throw UndefinedApiBehaviour();
}

MineImplWin32::~MineImplWin32()
{
    ::SetEvent(stopMineThreadEvent_);
    ::WaitForSingleObject(thread_, INFINITE);
    ::CloseHandle(thread_);

    ::CloseHandle(stopMineThreadEvent_);
    ::CloseHandle(orderReceivedEvent_);
}

void MineImplWin32::setTimer(Seconds seconds)
{
    if (INFINITE == timeToBoomInSec_)
    {
        timeToBoomInSec_ = seconds.num_;
        ::SetEvent(orderReceivedEvent_);
    }
}

void MineImplWin32::turnoff()
{
    if (INFINITE != timeToBoomInSec_)
    {
        timeToBoomInSec_ = INFINITE;
        ::SetEvent(orderReceivedEvent_);
    }
}

#else // if not defined _WIN32

MineImplPthreads::MineImplPthreads(DamageAgent* damageAgent)
: damageAgent_(damageAgent)
, timeToBoomInSec_(-1)
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
    timeToBoomInSec_ = seconds.num_;
    pthread_cond_signal(&orderReceivedCv_);
    pthread_mutex_unlock(&orderReceived_);
}

void MineImplPthreads::turnoff()
{
    pthread_mutex_lock(&orderReceived_);
    if (-1 != timeToBoomInSec_)
    {
        timeToBoomInSec_ = -1;
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
        if (-1 == mineImpl->timeToBoomInSec_)
        {
            // infinitely wait order
            rc = pthread_cond_wait(&mineImpl->orderReceivedCv_, &mineImpl->orderReceived_);
        }
        else
        {
            abstime.tv_sec = time(NULL) + mineImpl->timeToBoomInSec_;
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

void Mine::turnoff()
{
    impl_->turnoff();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LUA_CLASS(Mine)
{
    ADD_CONSTRUCTOR(Mine);
    ADD_DESTRUCTOR(Mine);

    ADD_METHOD(Mine, setTimer);
    ADD_METHOD(Mine, turnoff);
}

} // namespace YUNIT_NS {

DEFINE_LUA_TO(YUNIT_NS::Mine);

namespace YUNIT_NS {

extern "C"
int YUNIT_API LUA_SUBMODULE(mine)(lua_State* L)
{
    Lua::State lua(L);
    LUA_REGISTER(Mine)(lua);
    lua.push(true);
    return 1;
}

LUA_CONSTRUCTOR(Mine)
{
    static ProcessKiller procKiller;

    LUA_PUSH(new Mine(&procKiller), Mine);
    return 1;
}

LUA_DESTRUCTOR(Mine)
{
    enum Args {selfIdx = 1};
    Mine *mine = lua.to<Mine*>(selfIdx);
    lua_gc(lua, selfIdx);
    delete mine;

    return 0;
}

LUA_METHOD(Mine, sleep)
{
    enum Args {timeoutInSecIdx = 1};

    if (!lua.isinteger(timeoutInSecIdx))
        lua.error("integer expected as argument, but was %s", lua.typeName(timeoutInSecIdx));

    sleep(Seconds(lua.to<unsigned long>(timeoutInSecIdx)));
    return 0;
}

LUA_METHOD(Mine, setTimer)
{
    enum Args {selfIdx = 1, timeoutInSecIdx};

    if (!lua.isinteger(timeoutInSecIdx)) /// @todo Replace is some macro as CHECK_ARG_TYPE
        lua.error("integer expected as argument, but was %s", lua.typeName(timeoutInSecIdx));

    Mine *mine = lua.to<Mine*>(selfIdx);
    mine->setTimer(Seconds(lua.to<unsigned long>(timeoutInSecIdx)));

    return 0;
}

LUA_METHOD(Mine, turnoff)
{
    enum Args {selfIdx = 1};
    lua.to<Mine*>(selfIdx)->turnoff();
    return 0;
}

} // namespace YUNIT_NS
