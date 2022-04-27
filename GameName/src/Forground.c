/* Forground.c */

//By: Julian Zelazny

/*
This file covers the scrolling ground
*/

#include ".\src\Forground.h"

//things in pak file that we want
//Forgrounds/forground_colors.bin
//Forgrounds/forground_gfx.bin
//Forgrounds/forground_tilemap.bin

static FILE* filePtr;
static VDPVramNode_t* tilePtr;


void loadForground(void){
        int i;
        uint16_t vdpDataShadow;
	uint16_t data;
	uint16_t data2;

        VDP_Disable(DISPLAY);
        WaitForVblank();
        disableCPUInterrupts();

//load the colors to the color buffer
        filePtr = fopen("Forgrounds/forground_colors.bin");
        memcpy(colorBuffer+48,filePtr->data,filePtr->size);
	VDP_CommitColorBuffer();
        fclose(filePtr);

//load, allocate and DMA the graphics to the VDP
        filePtr = fopen("Forgrounds/forground_gfx.bin");
        tilePtr = VDP_AllocVram(filePtr->size/BYTES_PER_TILE);
	DMA_MemoryToVram(tilePtr->vramAddress, filePtr->size, filePtr->data,2);
        fclose(filePtr);

//load the tilemap to nametable A
        filePtr = fopen("Forgrounds/forground_tilemap.bin");

        //write to where we want to load things
        vdpDataShadow = DEFAULT_LAYER_A_ADDR - 128;

        for(i = 0; i < filePtr->size; i++){

        	if (!(i % 64)){
        		vdpDataShadow += 128;
        		VDP_CTRL_32 = VDP_WriteCommand(vdpDataShadow, VRAM_WRITE);
        	}

        	data = ((uint8_t*)filePtr->data-1)[i];
        	data <<=8;
        	data |= ((uint8_t*)filePtr->data)[i];

        	data2 = tilePtr->vramAddress;
        	data2 /=32;
        	data += data2;

        	VDP_DATA_16 = data << 8 | (data >> 8);
        }

        vdpDataShadow = DEFAULT_LAYER_A_ADDR - 128 + 64;

        for(i = 0; i < filePtr->size; i++){

        	if (!(i % 64)){
        		vdpDataShadow += 128;
        		VDP_CTRL_32 = VDP_WriteCommand(vdpDataShadow, VRAM_WRITE);
        	}

        	data = ((uint8_t*)filePtr->data-1)[i];
        	data <<=8;
        	data |= ((uint8_t*)filePtr->data)[i];

        	data2 = tilePtr->vramAddress;
        	data2 /=32;
        	data += data2;

        	VDP_DATA_16 = data << 8 | (data >> 8);
        }

        fclose(filePtr);

        //move the screen down a little to show more of the grass
        VSRamBuffer[0] = 0x08;
        VDP_CommitVSRAMBuffer();

        //copy the ground graphics to both sides of nametable A
        VDP_Enable(DISPLAY);
        enableCPUInterrupts();
}
