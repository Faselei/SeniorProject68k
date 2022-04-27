/* SystemCtrl.c */

//By: Julian Zelazny 01/13/22

/*
description:
System Controls:

	WaitForVblank, call this when we have nothing to do
	panic: system had a non-interrupt fatal error

*/

#include <SystemCtrl.h>
////////////////////////////////////////////////////////////////////////////////
/* WaitForVblank:
Spins the CPU in a busy wait,
will return once a v_irq is issues.
*/
void WaitForVblank() {
	uint32_t localTime;

	//get current time
	localTime = clock;

	//and spin until time advances
	while (localTime == clock);

	return;
}
////////////////////////////////////////////////////////////////////////////////
/* Panic:
	spin forever
*/
void Panic(){

//	VDP_CTRL_16 = 0x8000;
	for(;;);
		__asm("	stop	#$2700");
}

////////////////////////////////////////////////////////////////////////////////
void disableCPUInterrupts(void){
	__asm("	move	#$2700,sr");
}
////////////////////////////////////////////////////////////////////////////////
void enableCPUInterrupts(void){
	__asm("	move	#$2500,sr");
}
