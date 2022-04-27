/* init.c */

//By: Julian Zelazny

/*
main.c was getting full of stuff, so I moved the init code to this file
-Julian
*/

#include ".\src\init.h"

FILE*	file;			//how we load files
VDPVramNode_t* tilePtr;		//SolidColors.bin
VDPVramNode_t* tile2Ptr;	//temp
VDPVramNode_t* tile3Ptr;	//ascii2.bin

////////////////////////////////////////////////////////////////////////////////
void initGame(void){

        //enable V interrupts from the VDP
        VDP_Enable(V_INTERRUPT);

        //set VDP to NTSC
        VDP_SetVideoRegion(NTSC);

        //set screen width
        VDP_SetScreenWidth(SCREEN_32);
        //	error = VDP_SetScreenWidth(SCREEN_40);

        //allocate tiles in VRAM, this requires more testing
        tilePtr = VDP_AllocVram(16);	//solid color tiles
        tile2Ptr = VDP_AllocVram(16);	//reserved for now
        tile3Ptr = VDP_AllocVram(128);	//ascii text
        VDP_FreeVram(tile2Ptr);

        //load the ascii tileset and solid colors to vram
        file = fopen("ventureAscii.bin");
        DMA_MemoryToVram(tile3Ptr->vramAddress, file->size, file->data,2);
        fclose(file);

        file = fopen("SolidColors.bin");
        DMA_MemoryToVram(tilePtr->vramAddress, file->size, file->data,2);
        fclose(file);

        //init actors
        initActorSubsystem();

        /*start the game, I guess? we just need to call this as the 'GO!' thingy.
        	1. 'on your mark' = initSegaGenesis();
        	2. 'get set ' = everything else
        	3. 'GO!' = VDP_StartCPUHandshake();
        */
        VDP_StartCPUHandshake();

        //handshake has been started, we can committed things to DMA will now do
        VDP_CommitColorBuffer();
        VDP_CommitVSRAMBuffer();

        //this can crash horribly
        initCamera();		//must call this before testLoadNewStage();
//        testLoadNewStage();

        //load the background image and knight sprite
        LoadBackground();	//final
        loadForground();
        //	spawnSprite(&testActor);
        spawnKnightSprite();	//temp
//        initArchers();

        //turn the display on
        VDP_Enable(DISPLAY);
        WaitForVblank();	//make sure dma-buffers are empty
}
