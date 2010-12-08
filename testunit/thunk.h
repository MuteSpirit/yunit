#ifdef _MSC_VER
#pragma once
#endif
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// thunk.h
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef TESTUNIT_API
#	if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#		if defined(AFL_STATIC_LINKED)
#			define TESTUNIT_API
#		elif defined(AFL_DLL)
#			define TESTUNIT_API __declspec(dllimport)
#		else
#			define TESTUNIT_API __declspec(dllexport)
#		endif
#	else
#	   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#			define TESTUNIT_API __attribute__ ((visibility("default")))
#	   else
#			define TESTUNIT_API
#	   endif
#	endif
#endif

class TESTUNIT_API Thunk
{
public:
    Thunk() throw();

    template<typename T, void (T::* funcPtr)()>
    static Thunk create(T* thisPtr) throw();

    void invoke();

private:
    Thunk(void (* thunkPtr)(void*), void* thisPtr) throw();

    template<typename T, void (T::* funcPtr)()>
    static void thunk(void* thisPtr) throw();

    void (* thunkPtr_)(void*);
    void* thisPtr_;
};


template<typename T, void (T::* funcPtr)()>
Thunk Thunk::create(T* thisPtr) throw()
{
    return Thunk(&thunk<T, funcPtr>, thisPtr);
}

template<typename T, void (T::* funcPtr)()>
void Thunk::thunk(void* thisPtr) throw()
{
    (static_cast<T*>(thisPtr)->*funcPtr)();
}
