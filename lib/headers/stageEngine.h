/* stageEngine.h */

#ifndef STAGE_ENGINE_H
#define STAGE_ENGINE_H

#include <string.h>
#include <dma.h>
#include <DynamicMemory.h>
#include <vdp.h>
#include <SystemCtrl.h>
#include <camera.h>
#include <SegaDef.h>
#include <modulo.h>

typedef struct stage_t {
	uint8_t* stageData;
	uint16_t** mettaTileData;

	struct {
		uint8_t* data;
		uint16_t* numBytes;
		uint8_t numTiles;
	}tiles;

	camera_t camera;

	struct {
		uint16_t x;
		uint16_t y;
	}player;
}stage_t;

extern stage_t currentStage;

void loadNewStage(stage_t* stage);
void loadMapHorizontal(char direction);
//void loadMapVertical(char direction);
void testLoadNewStage(void);

//get the tile at x,y cord in tiles
uint8_t getTileAtPosition(uint8_t x, uint8_t y);

#endif //STAGE_ENGINE_H
