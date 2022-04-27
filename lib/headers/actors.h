/* actors.h */

#ifndef ACTORS_H
#define ACTORS_H

#include <stdint.h>
#include <string.h>
#include <vdp.h>
//#include <joypad.h>

#define MAX_ACTORS 16

//Number of 8x8 pixel tiles in ntsc mode, pal config can have 80?!
#define MAX_SPRITES 64

//while the genesis can support up to 32x32 pixel stuff, i'm keeping it at
//8x8 for this game as that is what I am familiar with. -Julian Zelazny



/* structure of a actor_t object:

	void* actMethod:
		this is called once per renderAllActors(void) call
	char isActive:
		if 0, this space is empty, if non-zero it is the ID of the
 		sprite( 1 - 255 )

	uint8_t tiles.numTiles:
	number of tiles in the list

 */



typedef struct actorTile_t {
	uint16_t tile;
	struct {
		uint8_t x;
		uint8_t y;
	}offset;	//offset.x
}actorTile_t;

typedef struct actor_t {
	void* actMethod;
	char isActive;
	uint16_t graphicsOffset;
	struct {
		uint8_t	numTiles;
		actorTile_t* data;
	}tiles;
        short x;
        short y;
} actor_t;

//typedef needed for each sprite
typedef struct object_t {
	uint16_t y;
	uint16_t a;
	uint16_t b;
	uint16_t x;
}object_t;

//external variables that any other translation unit can use
extern actor_t actors[MAX_ACTORS];
extern object_t objectDefinition[MAX_SPRITES];
extern actor_t* thisActor;
extern actor_t testActor;

//function protos
void initActorSubsystem(void);
void renderAllActors(void);
void updateActors(void);
char  spawnSprite(actor_t* thisActor);

#endif //ACTORS_H
