/* fixedPointNumbers.h */

/*
ok I borrowed a lot of this from the source code of DOOM
https://github.com/id-Software/DOOM/blob/master/linuxdoom-1.10/m_fixed.h

you can look for some usage examples here
https://github.com/id-Software/DOOM/blob/master/linuxdoom-1.10/g_game.c
*/

#ifndef FIXEDPOINTNUMBERS_H
#define FIXEDPOINTNUMBERS_H

#include <stdint.h>

//fixed point
typedef int32_t fixed16_t;

//from DOOM
#define FRACBITS		16
#define FRACUNIT		(1<<FRACBITS)

//function prototypes

#endif //FIXEDPOINTNUMBERS_H
