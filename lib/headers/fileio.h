/* fileio.h */

#ifndef FILEIO_H
#define FILEIO_H

//needed things from other H files
#include <stdint.h>
#include <string.h>
#include <DynamicMemory.h>

//eof constant
#define EOF     -1

//typedef file struct
typedef struct {
        void*   data;
        int size;
}FILE;

//function prototypes
void InitFileSystem();
FILE* fopen(char* filename);
void fclose(FILE* file);
//int feof(FILE* file);
//char fgetc(FILE* file);

uint32_t flipEndian(uint32_t data);

#endif //FILEIO_H
