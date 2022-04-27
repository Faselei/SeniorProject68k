/* dynamicColors.h */

#ifndef DYNAMICCOLERS_H
#define DYNAMICCOLERS_H

#include <stdint.h>
#include <vdp.h>
#include <linkedList.h>

typedef struct colorAlloc_s colorAlloc_t;

//function proto's
void initDynamicColorSubsystem(void);
colorAlloc_t* allocateMoreColors(uint8_t amount);

#endif //DYNAMICCOLERS_H
