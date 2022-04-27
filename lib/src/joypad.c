/* joypad.c */

//By: Julian Zelazny

/*
routines for setting up 3-button joypad support
*/

#include <joypad.h>

uint8_t prevControllerInputs;
uint8_t controllerInputs;

/* only call once */
void initControllers(void){

        JOYPAD_CTRL_0 = 0x40;
        JOYPAD_CTRL_1 = 0x40;
        JOYPAD_DATA_0 = 0x40;
        JOYPAD_DATA_1 = 0x40;

        prevControllerInputs = 0;
        controllerInputs = 0;
}

/* ONLY CALL ONCE PER FRAME */
void updateControllerInputs(void){

        uint8_t temp1,temp2;

//update the state of the previous set of variables
        prevControllerInputs = controllerInputs;

//start reading controller inputs
        JOYPAD_DATA_0 = 0x40;
        __asm("  nop");
        __asm("  nop");
        __asm("  nop");
        __asm("  nop");
        temp1 = JOYPAD_DATA_0;

        JOYPAD_DATA_0 = 0;
        __asm("  nop");
        __asm("  nop");
        __asm("  nop");
        __asm("  nop");
        temp2 = JOYPAD_DATA_0;

//rearange bits in a way for easy reading
        temp1 &= 0x3f;
        temp2 &= 0x30;
        temp2 <<= 2;
        controllerInputs = temp2 | temp1;
        controllerInputs ^= 0xff;
}

bool isButtonHeldDown(controllerBits_t bits){

        if (controllerInputs & bits)
                return true;
        else
                return false;

}

bool isButtonJustPressed(controllerBits_t bits){

        uint16_t temp;

//check what bits have changed
        temp = controllerInputs ^ prevControllerInputs;

//and with current joypad bits to see what was just pressed down
        temp &= controllerInputs;

        if (temp & bits)
                return true;
        else
                return false;
}

bool isButtonJustReleased(controllerBits_t bits){
        uint16_t temp;

//check what bits have changed
        temp = controllerInputs ^ prevControllerInputs;

//and with current joypad bits to see what was just released
        temp ^= controllerInputs;

        if (temp & bits)
                return true;
        else
                return false;
}

uint8_t getRawControllerInputs(void){
        return  controllerInputs;
}

void setRawControllerInputs(uint8_t data){
        controllerInputs = data;
}
