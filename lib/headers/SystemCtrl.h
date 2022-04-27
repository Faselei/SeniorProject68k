/* SystemCtrl.h */

#ifndef SYSTEMCTRL_H
#define SYSTEMCTRL_H

#include <stdint.h>

extern volatile uint32_t clock;

void WaitForVblank();
void Panic();
void disableCPUInterrupts(void);
void enableCPUInterrupts(void);


#endif //SYSTEMCTRL_H
