/* archer.c */

//By: Julian Zelazny

/*
Archer Enemy
*/

#include ".\src\archer.h"

typedef struct actorImage_t{
        actorTile_t* layout;
        uint8_t* tileData;
}actorImage_t;

#define MAX_WALK_FRAMES 1

actorImage_t idle;
actorImage_t walkFrames[MAX_WALK_FRAMES];

char archerGraphicsStrings[][32] = {
        "archer/archerWalk1_gfx.bin"
};

char archerTileMapStrings[][32] = {
        "archer/archerWalk1_tilemap.bin"
};

//

////////////////////////////////////////////////////////////////////////////////
//actor struct
actor_t archerActor = {
        NULL,   //act method
        2,      //actor number
        0,      //default graphics offset
        0,      //num tiles
        NULL,      //tile data ptr
        0,      //x
        0      //y
};
////////////////////////////////////////////////////////////////////////////////
void initArchers(void){
        FILE* filePtr;
        uint8_t i,j;

//load and commit the colors
        filePtr = fopen("archer/archerColor.bin");
	memcpy(colorBuffer+38,((uint8_t*)filePtr->data)+2,filePtr->size-2);
	VDP_CommitColorBuffer();
	fclose(filePtr);

//load the idle graphics

//load and convert all the walking graphics
        for( i = 0; i < MAX_WALK_FRAMES; i++){

                filePtr = fopen(archerGraphicsStrings[i]);      //open file
                walkFrames[i].tileData = malloc(filePtr->size); //make a buffer

                for (i = 0; i < filePtr->size; i++)     //convert to color index
                        walkFrames[i].tileData[i] *= 5;

                fclose(filePtr);
        }
}

////////////////////////////////////////////////////////////////////////////////
void spawnArcher(bool left){
        char actorIndex;
        char padding;
        FILE* filePtr;

//can we allocate more enemies?
        actorIndex = spawnSprite(&archerActor);
        if (actorIndex == -1){ //could not

        } else { //actor spawned

        }
}
