/* stageEngine.c */

//By: JulianZelazny

/*
This is the major tile background engine for the stage
Has a huge flaw when it comes to scrolling in 2 directions, so I stubbed
out the code for scrolling up / down and limited it to just left and right.

*/

#include <stageEngine.h>

//static
stage_t currentStage;

static struct {
//        uint16_t v[64];
        uint16_t h[64];
}tileBuffer;


/*
everything from here to uint16_t* stageMettaTiles is suppost to be a bin file
in pak0.pak, but for development purposes they exist here temp. untill
I move them to a stage1.bin in the pak file.
-Julian Zelazny 03/11/2022
*/

//uint8_t stageData[256] = {
uint8_t stageData[64] = {
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x01,
0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x03,0x02,0x01,
0x03,0x01,0x03,0x01,0x03,0x01,0x03,0x01,0x03,0x01,0x03,0x01,0x03,0x01,0x03,0x01,
0x01,0x03,0x01,0x03,0x01,0x03,0x01,0x03,0x00,0x03,0x00,0x03,0x00,0x03,0x00,0x03
/*,
0x01,0x03,0x01,0x03,0x01,0x03,0x01,0x03,0x01,0x03,0x01,0x03,0x01,0x03,0x01,0x03,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01,0x01
*/
};

uint16_t blank2[256] = {
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
};

uint16_t blank[256] = {
0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,0x000E,0x000F,
0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,0x000E,0x000F,0x0000,
0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,0x000E,0x000F,0x0000,0x0001,
0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,0x000E,0x000F,0x0000,0x0001,0x0002,
0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,0x000E,0x000F,0x0000,0x0001,0x0002,0x0003,
0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,0x000E,0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,
0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,0x000E,0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,
0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,0x000E,0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,
0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,0x000E,0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,
0x0009,0x000A,0x000B,0x000C,0x000D,0x000E,0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,
0x000A,0x000B,0x000C,0x000D,0x000E,0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,
0x000B,0x000C,0x000D,0x000E,0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,
0x000C,0x000D,0x000E,0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,
0x000D,0x000E,0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,
0x000E,0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,
0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,0x000E
};

uint16_t floor[256] = {
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x000E,0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,
0x000F,0x0000,0x0001,0x0002,0x0003,0x0004,0x0005,0x0006,0x0007,0x0008,0x0009,0x000A,0x000B,0x000C,0x000D,0x000E,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
};



uint16_t* stageMettaTiles[256] = {
        blank2, blank, 0x00000000,floor
};

stage_t testStage = {
        stageData,
        stageMettaTiles,
        NULL,   //pointer to tile data
        0,      //number of bytes
        0,      //number of tiles
        0,      //stage camera x
        0,      //stage camera y
        0x0000, //player init x
        0x0000  //player init y
};

////////////////////////////////////////
//

void testLoadNewStage(void){

//move the test stage to ram so we can modify it


//now load the stage to the VDP
        loadNewStage(&testStage);
}


////////////////////////////////////////
//loadNewStage
void loadNewStage(stage_t* stage){

        uint16_t i,j,k;
        struct {
                uint8_t macro;
                uint16_t micro;
        }mettaTile;

//save this stage as the new stage we are working with
        memcpy(&currentStage,stage,sizeof(stage_t));

//the whole nametable configuration is 64x64, so for each block of 16x16
        for(i = 0; i < 2; i++){ //hight
                for(j = 0; j < 2; j++){ //width

                        //what metta tile are we working with?
                        mettaTile.macro = stage->stageData[i*16+j+(stage->camera.y/128)*16+(stage->camera.x/128)];
                        mettaTile.micro = *stage->mettaTileData[mettaTile.macro];

                        //for each byte in the micro metta tile
                        for(k = 0; k < 16; k++){
//void DMA_MemoryToVram(uint16_t dest, uint16_t size, void* source);
                                DMA_MemoryToVram(DEFAULT_LAYER_A_ADDR+k*128+(j*32)+(i*2048),32,stage->mettaTileData[mettaTile.macro]+k*16,2);
                        //        WaitForVblank();
                        }
                        WaitForVblank();
                }
        }
}

//make sure that the camers stays in bounds
void wrapCamera(void){
        if( currentStage.camera.x < 0)
                currentStage.camera.x += 2048;

        if( currentStage.camera.x > 2048)
                currentStage.camera.x -= 2048;

        if( currentStage.camera.y < 0)
                currentStage.camera.y += 2048;

        if( currentStage.camera.y > 2048)
                currentStage.camera.y -= 2048;
}

//get the tile at x,y cord in tiles
uint8_t getTileAtPosition(uint8_t x, uint8_t y){

        uint8_t chunk;
        uint8_t tileIndex;

//find out the chunk number
        chunk = (((y/16)*256)/16) + x/16;

//get the tile index in the chunk
        tileIndex = ((y%16)*16) + x%16;

        return  currentStage.mettaTileData[currentStage.stageData[chunk]][tileIndex];
}




//load a 32 byte strip in the horizontal direction
//direction:
//left = 0;
//right = 1;
void loadMapHorizontal(char direction){

        uint32_t i;
        uint16_t vramAddress;

        struct {
                uint8_t x;
                uint8_t y;
        }tilePos;

        wrapCamera();

//get the tile pos by camera position
        tilePos.x = (currentStage.camera.x / 8);
        tilePos.y = (currentStage.camera.y / 8);

//left = 0;
//right = 1;
        if (direction)//{ //right
                tilePos.x += 32;
//        } else { //left
//        }

//start reading all the data from the stage and populate the buffers
                for (i = 0; i < 64; i++)
                        tileBuffer.h[i] = getTileAtPosition(tilePos.x, tilePos.y + i);

//write the DMA commands needed to commit the buffer we just filled
                vramAddress = ((tilePos.x)%64)*2;
                DMA_MemoryToVram(DEFAULT_LAYER_A_ADDR + vramAddress,128, tileBuffer.h, 128);
}


/*

//load a 32 byte strip in the virtucal direction
//direction:
//up = 0;
//down = 1;
void loadMapVertical(char direction){

        uint32_t i;
        uint16_t vramAddress;

        struct {
                uint8_t x;
                uint8_t y;
        }tilePos;

        wrapCamera();

//get the tile pos by camera position
        tilePos.x = (currentStage.camera.x / 8);
        tilePos.y = (currentStage.camera.y / 8);

//up = 0;
//down = 1;
        if (direction){ //down

//fill the buffer with tiles to draw
                for (i = 0; i < 32; i++)
                        tileBuffer.v[i] = getTileAtPosition(tilePos.x + i, tilePos.y + 28);

//                      vramAddress = ((tilePos.x + i)%64)*2 + (((tilePos.y + 32)*64)%4096)*2;

//if the x drawing will go off the edge of the screen bounds, we need 2 DMA's
                        if (tilePos.x % 64 > 32){

                                //first draw the y pos only dma
                                vramAddress = (((tilePos.y + 28)*64)%4096)*2;
                                DMA_MemoryToVram(DEFAULT_LAYER_A_ADDR + vramAddress,(tilePos.x % 64 - 32) * 2, tileBuffer.v, 2);

                                //now the y + x
                                vramAddress += ((tilePos.x)%64)*2;
                                DMA_MemoryToVram(DEFAULT_LAYER_A_ADDR + vramAddress,64 - (tilePos.x % 64 - 32) * 2, tileBuffer.v, 2);

                        } else { //we can use a single DMA
                                vramAddress = ((tilePos.x)%64)*2 + (((tilePos.y + 28)*64)%4096)*2;
                                DMA_MemoryToVram(DEFAULT_LAYER_A_ADDR + vramAddress, 64, tileBuffer.v, 2);
                        }


        } else { //up

                for (i = 0; i < 32; i++)
                        tileBuffer.v[i] = getTileAtPosition(tilePos.x + i, tilePos.y);

                        if (tilePos.x % 64 > 32){

                                //first draw the y pos only dma
                                vramAddress = (((tilePos.y)*64)%4096)*2;
                                DMA_MemoryToVram(DEFAULT_LAYER_A_ADDR + vramAddress,(tilePos.x % 64 - 32) * 2, tileBuffer.v, 2);

                                //now the y + x
                                vramAddress += ((tilePos.x)%64)*2;
                                DMA_MemoryToVram(DEFAULT_LAYER_A_ADDR + vramAddress,64 - (tilePos.x % 64 - 32) * 2, tileBuffer.v, 2);

                        } else { //we can use a single DMA
                                vramAddress = (((tilePos.y)*64)%4096)*2 + ((tilePos.x)%64)*2;
                                DMA_MemoryToVram(DEFAULT_LAYER_A_ADDR + vramAddress, 64, tileBuffer.v, 2);
                        }
        }
}
*/
