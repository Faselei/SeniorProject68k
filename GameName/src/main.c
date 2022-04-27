/* main.c */

/*

Main C file that the library calls once the hardware is set up.

State of hardware once int main(void) is called.
1. VDP display is disabled
2. All sound is silent
3. Z80 is off
4. TMSS disabled
5. System is Set to NTSC

*/

#include <Library.h>
#include ".\src\statusBar.h"
#include ".\src\init.h"

/* Global variables */
	colorAlloc_t* testColorAlloc;
	fixed16_t fixedNum;	//used in screen scrolling

////////////////////////////////////////////////////////////////////////////////
//main
int main(void){

//init hardware
	initSegaGenesis();

//init game
	initGame();

//init status bar
	initStatusBar();

//run forever
	fixedNum = 0;
	while(true){	//MAIN LOOP

//put player x,y as the score for testing
		score = (actors[0].y << 16) + actors[0].x;

//render all actors, and run the actor's act methods
		updateActors();

//update fixed point number scrolling
		fixedNum += 1 << FRACBITS - 2;	//0.25

//and apply them to the scrolling values as whole numbers
		hScroll = fixedNum >> FRACBITS;
		currentStage.camera.x = fixedNum >> FRACBITS;
//		loadMapHorizontal(1);

//we use the score as a temporary debug value
		runUpdateStatusBar = true;
		updateStatusBar();

//wait for the next frame
		WaitForVblank();
	}

//do not reach this statment
	return 0;
}
