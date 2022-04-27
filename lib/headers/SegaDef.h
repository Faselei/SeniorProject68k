/* SegaDef.h */

//all of the sega genesis hardware registers in C form

#ifndef SEGADEF_H
#define SEGADEF_H

#include <stdint.h>

//TMSS thing's
#define	VERSION	(*(uint8_t*) 0xA10001)
#define TMSS	(*(uint32_t*) 0xA14000)

//VDP registers
#define VDP_DATA_16	(*(uint16_t*) 0xC00000)
#define VDP_DATA_32	(*(uint32_t*) 0xC00000)
#define VDP_CTRL_16	(*(uint16_t*) 0xC00004)
#define VDP_CTRL_32	(*(uint32_t*) 0xC00004)
#define VDP_HVCOUNTER	(*(uint16_t*) 0xC00008)

//controller I/O
#define JOYPAD_CTRL_0	(*(uint8_t*) 0xA10009)
#define JOYPAD_CTRL_1	(*(uint8_t*) 0xA1000B)
#define JOYPAD_DATA_0	(*(uint8_t*) 0xA10003)
#define JOYPAD_DATA_1	(*(uint8_t*) 0xA10005)

//Pre-defined Methods
	void	initSegaGenesis();


#endif //SEGADEF_H
