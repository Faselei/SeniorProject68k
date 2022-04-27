/* actors.c */

//By: Julian Zelazny

#include <actors.h>

/*
description

rules when using act Methods: if it is set to a non-zero value, the
CPU will call it as a function.

methods cannot have parameters, so to access the data of that actor, please
refere to the global varialbe 'thisActor' pointer to access who called the
method.

therefore the C callback must be defined as such
void function(void);

to link with a actor you set with this

	actors[0].actMethod = (void*)&actorTestMethod1;
	actor->actMethod = (void*)&actorTestMethod1;

*/
////////////////////////////////////////////////////////////////////////////////
actor_t actors[MAX_ACTORS];
object_t objectDefinition[MAX_SPRITES];

actor_t* thisActor;

uint8_t savedActorIndex;
uint8_t padding;
////////////////////////////////////////////////////////////////////////////////
//test Actor

actorTile_t testActorTiles[] = {
	0x30,0,0,
	0x31,8,0,
	0x32,0,8,
	0x33,8,8
};

actor_t testActor = {
        NULL,   //act method
        1,      //actor number
        0,      //default graphics offset
        4,      //num tiles
        testActorTiles,      //tile data ptr
        0,      //x
        0      //y
};

////////////////////////////////////////////////////////////////////////////////
//void initActorSubsystem(void)
void initActorSubsystem(void){
        memset(&actors, 0, MAX_ACTORS * sizeof(actor_t));
        memset(&objectDefinition, 0, MAX_SPRITES * sizeof(object_t));
	thisActor = NULL;
	savedActorIndex = 0;
}

////////////////////////////////////////////////////////////////////////////////
//void runCallBack(void* address)

//trying to get C to generate these 2 instructions was too difficult,
//so I had to type them out myself -Julian Zelazny
void runCallBack(void* address){
        __asm(" move.l  (8,a5),a0");
        __asm(" jsr     (a0)");
}

////////////////////////////////////////////////////////////////////////////////
//void updateActors(void)
void updateActors(void){
        int i;

        //for each actor
        for(i = 0; i < MAX_ACTORS; i++){

                //see if this actor is active, skip if not
                if(actors[i].isActive == false)
                        continue;

                //run its act method if it has one
                if(actors[i].actMethod != NULL){
                        thisActor = &actors[i];
                        runCallBack(actors[i].actMethod);
                }
        }

	//now we can render all actors
	renderAllActors();
}

////////////////////////////////////////////////////////////////////////////////
//void renderAllActors(void)
void renderAllActors(void){
	char	remainingObjects;
	uint8_t actorIndex;
	uint8_t actorObjectIndex;
	uint8_t objectArrayIndex;
	actor_t* currentActor;
	object_t* currentObject;

//init variables
	remainingObjects = MAX_SPRITES;
	actorIndex = savedActorIndex;
	objectArrayIndex = 0;

/* DESTROYS CPU PERFORMANCE
	while(remainingObjects > 0){	//spin forever untill we run out of objects
*/
	for(actorIndex = 0; actorIndex < MAX_ACTORS; actorIndex++){

		currentActor = &actors[actorIndex];

//make sure that we have enough objects to render this actor
		if ((remainingObjects -= currentActor->tiles.numTiles) < 0)
			break;

//we now loop through all tiles in this actor
		for(actorObjectIndex = 0; actorObjectIndex < currentActor->tiles.numTiles; actorObjectIndex++){
			objectDefinition[objectArrayIndex].y = currentActor->y + 128 + currentActor->tiles.data[actorObjectIndex].offset.y;
			objectDefinition[objectArrayIndex].a = objectArrayIndex + 1;
			objectDefinition[objectArrayIndex].b = currentActor->tiles.data[actorObjectIndex].tile + currentActor->graphicsOffset; //'0' + actorObjectIndex;
			objectDefinition[objectArrayIndex].x = currentActor->x + 128 + currentActor->tiles.data[actorObjectIndex].offset.x;

			objectArrayIndex++;
		}

//cap the end of the list
		objectDefinition[objectArrayIndex].a = 0;

/*DESTROYS CPU PERFORMANCE
//move onto the next object, unless we are at the end
		actorIndex++;
		if (actorIndex == MAX_ACTORS)
			actorIndex = 0;
*/
	}

	//save the current index in case we
	savedActorIndex = actorIndex;

	//and finally commit the buffer at Vblank
	VDP_CommitSpriteBuffer();
}


////////////////////////////////////////////////////////////////////////////////
//char  spawnSprite(actor_t thisActor)

char  spawnSprite(actor_t* thisActor){

        uint8_t i;
        bool foundFreeSlot;

        foundFreeSlot = false;

//loop through all slots
        for(i = 0; i < MAX_ACTORS; i++){

                //if this slot is not free, then skip it
                if(actors[i].isActive != 0)
                        continue;
                else {
                        memcpy(&actors[i], thisActor, sizeof(actor_t));
						foundFreeSlot = true;
                        break;
                }
        }

        if (foundFreeSlot)
                return i;
        else
                return -1;
}
