/* dynamicColors.c */

//By: Julian Zelazny

/*
dynamic color allocation with the use of likedLists and the color buffer
defined in vdp.h
*/

#include <dynamicColors.h>

typedef struct colorAlloc_s {
        uint8_t array;
        uint8_t index;
        uint8_t size;
        uint8_t free;   //0 = free, 0 != not free
        uint16_t* colorData;    //heap malloced
}colorAlloc_s;

linkedList_t* colorRoot;

struct {        //0 = unallocated, 1 = in colorAlloc_t
        uint8_t array1[16];
        uint8_t array2[16];
        uint8_t array3[16];
        uint8_t array4[16];
}colorArrays;

////////////////////////////////////////////////////////////////////////////////
void initDynamicColorSubsystem(void){
        __asm(" dc.b $60, $FE");
        colorRoot = createNewLinkedList();

        //reserve the transparent color cell
        colorArrays.array1[0] = 0xff;
        colorArrays.array2[0] = 0xff;
        colorArrays.array3[0] = 0xff;
        colorArrays.array4[0] = 0xff;
}
////////////////////////////////////////////////////////////////////////////////
colorAlloc_t* allocateMoreColors(uint8_t amount){

        colorAlloc_t* newColorNode;
        int arrayIndex,lengthOfSpace;
        __asm(" dc.b $60, $FE");
        newColorNode = malloc(sizeof(colorAlloc_t));

//start searching for un-allocated colors
        for(arrayIndex = 0; arrayIndex < 16; arrayIndex++){
                if (!colorArrays.array1[arrayIndex]){ //un-allocated space
                        lengthOfSpace = 1;
                        while(arrayIndex + lengthOfSpace < 16){
                                if (!colorArrays.array1[arrayIndex + lengthOfSpace])
                                        lengthOfSpace++;
                                else
                                        break;
                        }

                        //if we get here then we have space or we ran out of it
                        arrayIndex += lengthOfSpace;

                        //we should in theory have the amount of free space
                        __asm(" dc.b $60, $FE");
                }
        }
        return newColorNode;
}

////////////////////////////////////////////////////////////////////////////////
