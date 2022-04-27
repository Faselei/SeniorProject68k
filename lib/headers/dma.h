/* dma.h */

#ifndef DMA_H
#define DMA_H


#include <stdint.h>
#include <vdp.h>

//constants
#define DMAQUEUE_MAX_ELEMENTS 24

//VDP DMA Constants
typedef enum {
	MAIN,
	FILL,
	COPY
}VDPDMAType_t;

typedef struct {
        VDPDMAType_t type;
	uint8_t autoIncValue;
        uint32_t dest;  //made by VDP_WriteCommand
        uint16_t size;


	union{
		uint32_t mainMemory;	//DMA memory to VDP
		uint8_t fill;		//DMA fill
		uint16_t source;	//DMA copy
	}custom;
}DMAQueueElement_t;

//function proto's
void DMA_MemoryToVram(uint16_t dest, uint16_t size, void* source, uint8_t autoIncValue);
void DMA_VramFill(uint16_t dest, uint16_t size, uint8_t fill, uint8_t autoIncValue);
void DMA_VramCopy(uint16_t dest, uint16_t size, uint16_t source, uint8_t autoIncValue);
void DMA_ColorBuffer();
void DMA_VSCRAM();
void DMA_Init();

#endif //BLANK_H
