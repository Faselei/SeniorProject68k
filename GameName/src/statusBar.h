/* statusBar.h */

#ifndef STATUS_BAR_H
#define STATUS_BAR_H

#include <stdint.h>
#include <string.h>
#include <dma.h>
#include <vdp.h>

//call once
void initStatusBar(void);

//call when you modify any of the variables associated with the status bar
void updateStatusBar(void);

extern uint32_t score;
extern uint8_t health;
extern bool runUpdateStatusBar;

#endif //STATUS_BAR_H
