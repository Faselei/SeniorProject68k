/* Background.c */

//By: Julian Zelazny

/*
This file displays the castle background image, the image loads to layer B of
the VDP. This file took me 6+ hours to do because the image is a series of
bytes. However, the C compiler reads only on even addresses; the 68000 throws
address errors when trying to read data at an odd address for any data type
that is not bytes. So to maintain consistency, this is applied to bytes as well.
This alignment threw me off for a long time until I inspected every instruction
and what data was written to memory before I figured out the issue.
My rage was quickly replaced with relief and joy when the CPU finally rendered
the background correctly. The byte alignment was just one of the myriad of
problems encountered, but this was the most troublesome and infuriating one.
*/

#include ".\src\Background.h"

/*
Here are the files we are going to need from the pak file:
Backgrounds/mountain_colors.bin	// colors
Backgrounds/mountain_gfx.bin	// tile data
Backgrounds/mountain_tilemap.bin	// nametable
*/

////////////////////////////////////////////////////////////////////////////////
//LoadBackground(void)
void LoadBackground(void){
	FILE* castleFilePtr;
	int i;
	uint16_t vdpDataShadow;
	uint16_t data;
	uint16_t data2;

//this does end up being a memory leak, but because this is the only background
//we can afford to have it, as that memory will never be freed
	VDPVramNode_t* tilePtr;

//disable rendering, wait the rest of the frame, then disable irq's
	VDP_Disable(DISPLAY);
	WaitForVblank();
	disableCPUInterrupts();

//load the castle and mountains from the pak file
	castleFilePtr = fopen("Backgrounds/mountain_colors.bin");

//the tilemap and data expect the colors to be loaded into slots 17-31
	memcpy(colorBuffer+16,castleFilePtr->data,castleFilePtr->size);
	VDP_CommitColorBuffer();
	fclose(castleFilePtr);

//load the tilemap to VRAM, and allocate the space for it
	castleFilePtr = fopen("Backgrounds/mountain_gfx.bin");
	tilePtr = VDP_AllocVram(castleFilePtr->size/BYTES_PER_TILE);	//solid color tiles

//we can move all this data without overflowing the DMA bandwidth because
//we have the display turned off, it does not turn back on untill AFTER
//the DMA queue is empty
	DMA_MemoryToVram(tilePtr->vramAddress, castleFilePtr->size, castleFilePtr->data,2);
	fclose(castleFilePtr);

//and finally load the tilemap to the screen
	castleFilePtr = fopen("Backgrounds/mountain_tilemap.bin");

//write to where we want to load things
	vdpDataShadow = DEFAULT_LAYER_B_ADDR - 128;

	for(i = 0; i < castleFilePtr->size; i++){

		if (!(i % 64)){
			vdpDataShadow += 128;
			VDP_CTRL_32 = VDP_WriteCommand(vdpDataShadow, VRAM_WRITE);
		}

//aparently the C compiler expects all bytes to be alligned with an even address
//this cost me 6+ hours to figure out
//luckely my rage was quickely replaced with happyness and relief when the
//background finally rendered correctlyS
		data = ((uint8_t*)castleFilePtr->data-1)[i];
		data <<=8;
		data |= ((uint8_t*)castleFilePtr->data)[i];

		data2 = tilePtr->vramAddress;
		data2 /=32;
		data += data2;

		VDP_DATA_16 = data << 8 | (data >> 8);
	}


	fclose(castleFilePtr);

	VDP_Enable(DISPLAY);
	enableCPUInterrupts();
}
