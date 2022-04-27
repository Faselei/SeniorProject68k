/* DynamicMemory.h */

#ifndef DYNAMICMEMORY_H
#define DYNAMICMEMORY_H

void*   malloc(uint16_t size);
void*   calloc(uint8_t n, uint16_t size);
void*   realloc(void* ptr, uint16_t size);
void    free(void* ptr);

#endif //DYNAMICMEMORY_H
