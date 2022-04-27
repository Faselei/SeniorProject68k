/* dma.c */

//By: Julian Zelazny

/*

This file is to work in conjunction with DMA_ProcessDmaQueue
found in dma_a.asm
*/

#include <dma.h>

uint8_t queueIndex;
bool processDMAQueue;
DMAQueueElement_t queueArea[DMAQUEUE_MAX_ELEMENTS];


////////////////////////////////////////
//DMA_MemoryToVram
void DMA_MemoryToVram(uint16_t dest, uint16_t size, void* source, uint8_t autoIncValue){

        DMAQueueElement_t* newElement;
        uint32_t fixedSource;
        //must set to false so we don't get processed half way through
        processDMAQueue = false;

        //link it to the current index in dma array
        newElement = &queueArea[queueIndex];

        //fill out the struct
        newElement->type = MAIN;
        newElement->autoIncValue = autoIncValue;
        newElement->size = (size / 2);
        newElement->dest = VDP_WriteCommand(dest,VRAM_DMA);
        newElement->custom.mainMemory = (((uint32_t)source >> 1) & 0x00FFFFFF);
        queueIndex++;

        //now we can process DMA's safely
        processDMAQueue = true;
}

////////////////////////////////////////
//DMA_VramFill
void DMA_VramFill(uint16_t dest, uint16_t size, uint8_t fill, uint8_t autoIncValue){
        DMAQueueElement_t* newElement;

        //must set to false so we don't get processed half way through
        processDMAQueue = false;

        //link it to the current index in dma array
        newElement = &queueArea[queueIndex];

        //fill out the struct
        newElement->type = FILL;
        newElement->autoIncValue = autoIncValue;
        newElement->size = size - 1;
        newElement->dest = VDP_WriteCommand(dest,VRAM_DMA);
        newElement->custom.fill = fill;
        queueIndex++;

        //now we can process DMA's safely
        processDMAQueue = true;
}

////////////////////////////////////////
//DMA_VramCopy
void DMA_VramCopy(uint16_t dest, uint16_t size, uint16_t source, uint8_t autoIncValue){
        DMAQueueElement_t* newElement;

        //must set to false so we don't get processed half way through
        processDMAQueue = false;

        //link it to the current index in dma array
        newElement = &queueArea[queueIndex];

        //fill out the struct
        newElement->type = COPY;
        newElement->autoIncValue = autoIncValue;
        newElement->size = size;            //DMA_copy needs 0xC0 and 0x80
        newElement->dest = VDP_WriteCommand(dest,VRAM_DMA | 0x000000C0);
        newElement->custom.source = source;
        queueIndex++;

        //now we can process DMA's safely
        processDMAQueue = true;
}
