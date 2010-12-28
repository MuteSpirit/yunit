#include "thunk.h"
//#include "signal.h"

Thunk::Thunk() throw()
: thunkPtr_(0), thisPtr_(0)
{}

Thunk::Thunk(void (* thunkPtr)(void*), void* thisPtr) throw()
: thunkPtr_(thunkPtr), thisPtr_(thisPtr)
{}

void Thunk::invoke()
{
    (*thunkPtr_)(thisPtr_);
}
