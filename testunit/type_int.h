//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// type_int.h
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _TYPE_INT_HEADER_
#define _TYPE_INT_HEADER_

namespace afl {

#if defined(_MSC_FULL_VER) && defined(_WIN32) && !defined(_WIN64)

	typedef signed __int8		int8_t;
	typedef __int16				int16_t;
	typedef __int32				int32_t;
	typedef __int64				int64_t;
	typedef unsigned __int8		uint8_t;
	typedef unsigned __int16	uint16_t;
	typedef unsigned __int32	uint32_t;
	typedef unsigned __int64	uint64_t;

	typedef __int32				int_fast8_t;
	typedef __int32				int_fast16_t;
	typedef __int32				int_fast32_t;
	typedef __int64				int_fast64_t;
	typedef unsigned __int32	uint_fast8_t;
	typedef unsigned __int32	uint_fast16_t;
	typedef unsigned __int32	uint_fast32_t;
	typedef unsigned __int64	uint_fast64_t;

	typedef __int32				int_t;
	typedef unsigned __int32	uint_t;

	typedef __int32				int_max_t;
	typedef unsigned __int32	uint_max_t;

	typedef __int32				int_ptr_t;
	typedef unsigned __int32	uint_ptr_t;

#elif defined(_MSC_FULL_VER) && defined(_WIN64)

	typedef signed __int8		int8_t;
	typedef __int16				int16_t;
	typedef __int32				int32_t;
	typedef __int64				int64_t;
	typedef unsigned __int8		uint8_t;
	typedef unsigned __int16	uint16_t;
	typedef unsigned __int32	uint32_t;
	typedef unsigned __int64	uint64_t;

	typedef __int64				int_fast8_t;
	typedef __int64				int_fast16_t;
	typedef __int64				int_fast32_t;
	typedef __int64				int_fast64_t;
	typedef unsigned __int64	uint_fast8_t;
	typedef unsigned __int64	uint_fast16_t;
	typedef unsigned __int64	uint_fast32_t;
	typedef unsigned __int64	uint_fast64_t;

	typedef __int64				int_t;
	typedef unsigned __int64	uint_t;

	typedef __int64				int_max_t;
	typedef unsigned __int64	uint_max_t;

	typedef __int64				int_ptr_t;
	typedef unsigned __int64	uint_ptr_t;

#else
	typedef int			    	int_t;
	typedef unsigned int	    uint_t;

	typedef int				    int_max_t;
	typedef unsigned int	    uint_max_t;

	typedef int				    int_ptr_t;
	typedef unsigned int	    uint_ptr_t;
#endif

} //namespace afl

#endif	//_TYPE_INT_HEADER_
