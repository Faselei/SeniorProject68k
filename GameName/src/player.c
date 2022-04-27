/* player.c */

//By: julian zelazny

/*
the knight sprite
*/
#include ".\src\player.h"
#include ".\src\statusBar.h"

static VDPVramNode_t* tilePtr;	//vram allocated for this actor
static actorTile_t* tileMap;	//how the sprite is assembled
static bool isMoving;
static uint8_t counter;
static fixed16_t currentTime;
static char actorIndex;	//its index in the actor table
static FILE* filePtr;		//for loading things from file

//in uint8_t
#define MAX_FRAMES 4

//in fixed16_t
#define MAX_TIME 2

char knightAnimationRunGFXFiles[][33] = {
	"knight/running/KnightRun1_gfx.bin",	//mid
	"knight/running/KnightRun2_gfx.bin",	//left
	"knight/running/KnightRun1_gfx.bin",	//mid
	"knight/running/KnightRun4_gfx.bin"	//right
};

char knightAnimationRunTilemapFiles[][37] = {
	"knight/running/KnightRun1_tilemap.bin",
	"knight/running/KnightRun2_tilemap.bin",
	"knight/running/KnightRun1_tilemap.bin",
	"knight/running/KnightRun4_tilemap.bin"
};

/*Knight graphics strings in pak file*/

//idle
//knight/knight_colors.bin	<-- this is a global color
//knight/knight_gfx.bin
//knight/knight_tilemap.bin

//running
//knight/running/KnightRun1_gfx.bin
//knight/running/KnightRun1_tilemap.bin
//knight/running/KnightRun2_gfx.bin
//knight/running/KnightRun2_tilemap.bin
//knight/running/KnightRun4_gfx.bin
//knight/running/KnightRun4_tilemap.bin

////////////////////////////////////////////////////////////////////////////////
//knight actor data
void knightTestMethod(void){

	isMoving = false;

	if (isButtonHeldDown(RIGHT)){
		thisActor->x++;
		isMoving = true;
	}

	if (isButtonHeldDown(LEFT)){
		thisActor->x--;
		isMoving = true;
	}

	if (isButtonHeldDown(DOWN)){
		thisActor->y++;
		isMoving = true;
	}

	if (isButtonHeldDown(UP)){
		thisActor->y--;
		isMoving = true;
	}


//bool isButtonJustReleased(controllerBits_t bits);
	if (isMoving == false && isButtonJustReleased(UP|DOWN|LEFT|RIGHT)){
//GRAPHICS
		filePtr = fopen("knight/knight_gfx.bin");
		VDP_FreeVram(tilePtr);
		tilePtr = VDP_AllocVram(filePtr->size/BYTES_PER_TILE);
		DMA_MemoryToVram(tilePtr->vramAddress, filePtr->size, filePtr->data,2);
		fclose(filePtr);
		VDP_CommitSpriteBuffer();

//TILEMAP
		filePtr = fopen("knight/knight_tilemap_smaller.bin");
		memcpy(tileMap, filePtr->data, filePtr->size);
		fclose(filePtr);
		currentTime = 0;
		return;
	}


//if we get here then we did not move or did we just release a button
	if (isMoving == false)
		return;

//the D-pad is activelly being pressed, mark that time has passed
	currentTime += 1 << FRACBITS - 3;	//0.125

//check if we should move onto the next frame
	if (currentTime >= MAX_TIME * FRACUNIT){ // 2.0
		currentTime = 0;
		counter++;

		//start repeating?
		if (counter >= MAX_FRAMES)
			counter = 0;

		//DMA new graphics over
		filePtr = fopen(knightAnimationRunGFXFiles[counter]);
		VDP_FreeVram(tilePtr);
		tilePtr = VDP_AllocVram(filePtr->size/BYTES_PER_TILE);
		DMA_MemoryToVram(tilePtr->vramAddress, filePtr->size, filePtr->data,2);
		fclose(filePtr);
		VDP_CommitSpriteBuffer();

		//tilemap
		filePtr = fopen(knightAnimationRunTilemapFiles[counter]);
		free(tileMap);
		tileMap = malloc(filePtr->size);
		memcpy(tileMap, filePtr->data, filePtr->size);
		fclose(filePtr);
	}
}

/*
actorTile_t knightActorTiles[] = {
	1,0,0,
	2,8,0,
	3,0,8,
	4,8,8,
	5,0,16,
	6,8,16,
	7,0,24,
	8,8,24,
	9,0,32,
	10,8,32
};*/

actor_t knightActor = {
        (void*)&knightTestMethod,   //act method
        1,      //actor number
        0,      //default graphics offset
        0,      //num tiles
        NULL,      //tile data ptr
        0,      //x
        0      //y
};

////////////////////////////////////////////////////////////////////////////////
void spawnKnightSprite(void){

	currentTime = 0;
	counter = 0;

//GRAPHICS
	filePtr = fopen("knight/knight_gfx.bin");
	tilePtr = VDP_AllocVram(filePtr->size/BYTES_PER_TILE);
	DMA_MemoryToVram(tilePtr->vramAddress, filePtr->size, filePtr->data,2);
	fclose(filePtr);
	VDP_CommitSpriteBuffer();

//COLORS
	filePtr = fopen("knight/knight_colors.bin");
	memcpy(colorBuffer+32,filePtr->data,filePtr->size);
	VDP_CommitColorBuffer();
	fclose(filePtr);

//TILEMAP
	filePtr = fopen("knight/knight_tilemap_smaller.bin");
	tileMap = malloc(filePtr->size);
	memcpy(tileMap, filePtr->data, filePtr->size);
	fclose(filePtr);

//finally spawn the actor itself
	actorIndex = spawnSprite(&knightActor);

//fill out a few extra things in the struct we need to modify
	actors[actorIndex].graphicsOffset = tilePtr->vramAddress/BYTES_PER_TILE;
	actors[actorIndex].tiles.numTiles = filePtr->size/4;	//num bytes for each object in sprite cache 4 bytes per
	actors[actorIndex].tiles.data = tileMap;

//actor position
	actors[actorIndex].x = 0x0070;
	actors[actorIndex].y = 0x00b0;
}
