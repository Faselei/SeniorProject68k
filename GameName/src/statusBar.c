/* statusBar.c */

//By: julian zelazny & david pease

#include ".\src\statusBar.h"

/*
status bar for score and health
*/

//variables that the game can modify
uint32_t score;
uint8_t health;
bool runUpdateStatusBar;

//buffer for what we send to the DMA subsystem
uint16_t statusBarBuffer[64];

//static srings
char scoreString[] = {
	"SCORE:"
};

char healthString[] = {
	"HEALTH:"
};

//call once
void initStatusBar(void){
	int i;
	size_t stringLength;

//set all the variables to a known value
	score = 0;
	health = 6;
	runUpdateStatusBar = true;

//copy the score string to its final place in the buffer
	stringLength = strlen(scoreString);
	for(i = 0; i < stringLength; i++)
		statusBarBuffer[i] = scoreString[i];

//copy the health string to its final place in the buffer
	stringLength = strlen(healthString);
	for(i = 0; i < stringLength; i++)
		(statusBarBuffer+32)[i] = healthString[i];

//display a bunch of zero's for the score
	for(i = 0; i < 8; i++)
		(statusBarBuffer+6)[i] = '0';

//display a bunch of one's for the health
	for(i = 0; i < 6; i++)
		(statusBarBuffer+39)[i] = '1';
}

//call when you modify any of the variables associated with the status bar
void updateStatusBar(void){
		uint32_t i, digit, base, decimal,temp;

//only update if the flag is set to true
	if (runUpdateStatusBar){

//update the on screen score
		decimal = 0;
		base = 1;
		for(i = 0; i < 8; i++){
			//(statusBarBuffer+6)[i] = '0' + ((decimal >> (28 - 4*i)) & 0x0f);
			temp = ((score >> (28 - 4*i)) & 0x0f);	//displays the score as hex
			if (temp > 9)
				temp += 7;
			(statusBarBuffer+6)[i] = '0' + temp;
		}

//update the health 'string' using the 'health' variable
		for(i = 0; i < 6; i++){

		}



//DMA the buffer to the screen, and mark that we don't need to do this again next frame
		DMA_MemoryToVram(DEFAULT_WINDOW_ADDR, 64*2, statusBarBuffer, 2);
		runUpdateStatusBar = false;
	}
}
