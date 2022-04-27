/* errno.h */

#ifndef ERRNO_H
#define ERRNO_H

typedef enum {
	NONE,
	FILE_NOT_FOUND,
	DOES_NOT_EXIST,
	BAD_ADDRESS,
	IO_ERROR,
	DEADLOCK,
	TOO_LONG,
	OUT_OF_MEMORY,
	OUT_OF_BOUNDS,
	UNKNOWN_INPUT
}errno_t;

//errno is defined in errno.inc in library source code
//	errno_t	errno;


#endif //ERRNO_H
