#ifdef _MSC_VER
#pragma once
#endif
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// thunk.h
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef AFL_API
#	if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#		if defined(AFL_STATIC_LINKED)
#			define AFL_API
#		elif defined(AFL_DLL)
#			define AFL_API __declspec(dllimport)
#		else
#			define AFL_API __declspec(dllexport)
#		endif
#	else
#	   if defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#			define AFL_API __attribute__ ((visibility("default")))
#	   else
#			define AFL_API
#	   endif
#	endif
#endif

class AFL_API Thunk
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
