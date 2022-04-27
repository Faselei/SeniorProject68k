/* camera.c */

//By: Author

#include <camera.h>

camera_t camera;

/*
description
*/

void initCamera(void){

        camera.x = 0;
        camera.y = 0;

}


short getCameraX(void){
        return camera.x;
}

short getCameraY(void){
        return camera.y;
}

void setCameraX(short x){
        camera.x = x;
}

void setCameraY(short y){
        camera.y = y;
}
