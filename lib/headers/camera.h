/* camera.h */

#ifndef CAMERA_H
#define CAMERA_H

typedef	struct camera_t {
	short x;
	short y;
}camera_t;

extern camera_t camera;

void initCamera(void);
short getCameraX(void);
short getCameraY(void);
void setCameraX(short x);
void setCameraY(short y);


#endif //CAMERA_H
