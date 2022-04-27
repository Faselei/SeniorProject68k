/* string.h */
//By: Julian Zelazny

#ifndef STRING_H
#define STRING_H

#include <stdint.h>

//maximum size
typedef uint32_t size_t;

//well we need to define what null is now do we?
#define NULL ((void*)0)
//#define NULL 0

//function prototypes
void* memchr(const void* str, int c, size_t n);
int memcmp(const void * str1, const void* str2, size_t n);
void* memcpy(void *dest, const void * src, size_t n);
void* memset(void *s, int c, size_t count);
size_t strlen(const char *str);
char* strcat(char *dest, const char *src);
char* strncat(char *dest, const char *src, size_t n);
char* strchr(const char *str, int c);
int strcmp(const char *str1, const char *str2);
int strncmp(const char *str1, const char *str2, size_t n);
char* strcpy(char *dest, const char *src);
char* strncpy(char *dest, const char *src, size_t n);
char* strrchr(const char *str, int c);
char* strtok(char *str, const char delim);
#endif //STRING_H
