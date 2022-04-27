/* vdp.h */

#ifndef VDP_H
#define VDP_H

#include <errno.h>
#include <stdint.h>


//constants
#define	DEFAULT_LAYER_A_ADDR 0xC000
#define DEFAULT_LAYER_B_ADDR 0xE000
#define DEFAULT_WINDOW_ADDR 0xB000
#define DEFAULT_SPRITE_ADDR 0xBE00

#define BYTES_PER_TILE 32

//enable / disable flags
typedef enum {
	H_INTERRUPT,
	HV_COUNTER,
	DISPLAY,
	V_INTERRUPT,
	DMA,
	EXT_INTERRUPT,
	SHADOW_HIGHLIGHT
}VDPToggle_t;

// Video Region
typedef enum {
	AUTO,
	NTSC,	//28 tiles tall
	PAL	//30 tiles tall, won't display correctly on NTSC TV's.
}VDPVideoRegion_t;

//Screen width
typedef enum {
	SCREEN_32,
	SCREEN_40
}VDPScreenWidth_t;

//VDP Memory Region
typedef enum {
	SCROLL_A,
	WINDOW,
	SCROLL_B,
	SPRITE,
	SCROLL_H
}VDPMemoryRegion_t;

//VDP commands
typedef enum {
	VRAM_WRITE = 0x40000000,
	CRAM_WRITE = 0xC0000000,
	VSRAM_WRITE = 0x40000010,
	VRAM_READ = 0x00000000,
	CRAM_READ = 0x00000040,
	VSRAM_READ = 0x00000020,
	VRAM_DMA = 0x40000080,
	CRAM_DMA = 0xC0000080,
	VSRAM_DMA = 0x40000090
}VDPCommand_t;

//VDP vram alloc type
typedef struct {
	uint16_t free;
	uint16_t vramAddress;
	uint16_t numTiles;
	uint16_t next;
}VDPVramNode_t;

//function prototypes
void 	VDP_Init();
void 	VDP_CommitShadowRegisters();

//VDP seting options
void	VDP_Enable(VDPToggle_t option);
void	VDP_Disable(VDPToggle_t option);
void	VDP_SetVideoRegion(VDPVideoRegion_t region);
void	VDP_SetScreenWidth(VDPScreenWidth_t setting);
void	VDP_SetHRate(uint8_t rate);
void	VDP_BackgroundColorIndex(uint8_t index);

//control of the VDP
void	VDP_StartCPUHandshake();
uint32_t	VDP_WriteCommand(uint16_t address, VDPCommand_t cmd);

//vram allocation and cleanup
VDPVramNode_t*	VDP_AllocVram(uint8_t numTiles);
void	VDP_FreeVram(VDPVramNode_t* node);

//DMA
void 	VDP_CommitColorBuffer(void);
void 	VDP_CommitVSRAMBuffer(void);
void	VDP_CommitSpriteBuffer(void);

//color and vsram buffers
extern uint16_t colorBuffer[64];
extern uint16_t VSRamBuffer[80];
extern short hScroll;

#endif //VDP_H
