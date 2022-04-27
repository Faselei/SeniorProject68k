/* blank.h */

#ifndef JOYPAD_H
#define JOYPAD_H

#include <stdint.h>
#include <SegaDef.h>

typedef enum {
//        NONE = 0x00,
        UP = 0x01,
        DOWN = 0x02,
        LEFT = 0x04,
        RIGHT = 0x08,
        B = 0x10,
        C = 0x20,
        A = 0x40,
        START = 0x80

}controllerBits_t;

//call this once
void initControllers(void);

//CALL THIS ONLY ONCE PER FRAME
void updateControllerInputs(void);

//general detection
bool isButtonHeldDown(controllerBits_t bits);
bool isButtonJustPressed(controllerBits_t bits);
bool isButtonJustReleased(controllerBits_t bits);

//get raw values
uint8_t getRawControllerInputs(void);

//set raw values (usefull for a demo mode)
void setRawControllerInputs(uint8_t data);

#endif //JOYPAD_H
