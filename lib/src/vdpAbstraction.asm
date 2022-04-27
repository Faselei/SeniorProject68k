;===============================================================================
;vdpAbstraction.asm
;===============================================================================
;abstraction layer for the VDP
;-------------------------------------------------------------------------------

	include "vdpAbstraction.inc"
	include "errno.inc"

;alloc struct valuse, might want to move them to vdpAbstraction.inc
VRAM_ALLOC_FREE equ 0
VRAM_ALLOC_VRAM equ 2
VRAM_ALLOC_NUM equ 4
VRAM_ALLOC_NEXT equ 6

VRAM_MAX_NUMTILES equ 2048

;///////////////////////////////////////////////////////////////////////////////
	section	"BSS",bss

;vdp shadow registers
	public	shadowVdp_address
shadowVdp_address:
shadowVdp_ModeReg1 ds.b 1
shadowVdp_ModeReg2 ds.b 1
shadowVdp_PlaneA ds.b 1
shadowVdp_Window ds.b 1
shadowVdp_PlaneB ds.b 1
shadowVdp_Sprite ds.b 1
	ds.b 1
shadowVdp_BGColor ds.b 1
	ds.b 1
	ds.b 1
shadowVdp_HRate ds.b 1
shadowVdp_ModeReg3 ds.b 1
shadowVdp_ModeReg4 ds.b 1
shadowVdp_HScroll ds.b 1
	ds.b 1
shadowVdp_Incr ds.b 1
shadowVdp_Size ds.b 1
shadowVdp_WinX ds.b 1
shadowVdp_WinY ds.b 1

shadowVdp_DMA_L_Low	ds.b	1
shadowVdp_DMA_L_High	ds.b	1
shadowVdp_DMA_S_Low	ds.b	1
shadowVdp_DMA_S_Mid	ds.b	1
shadowVdp_DMA_S_High	ds.b	1

;commit DMA flags
vdpCommitColorBufferFlag	ds.b	1
vdpCommitVSRAMBufferFlag	ds.b	1
vdpCommitSpriteBufferFlag	ds.b	1
	public	vdpCommitColorBufferFlag
	public	vdpCommitVSRAMBufferFlag
	public	vdpCommitSpriteBufferFlag
	even

;vram allocation start
allocVramStart	ds.l	1
allocVramEnd	ds.l	1
allocVramCurrent ds.w	1

;horizontal scroll word
_hScroll ds.w	1
	public	_hScroll

;DMA buffers
_colorBuffer ds.b CRAM_SIZE
_VSRamBuffer ds.b VSRAM_SIZE

	public	_colorBuffer
	public	_VSRamBuffer

;///////////////////////////////////////////////////////////////////////////////
	section	"DATA",data
vdpOptionsTable:
	dc.l	shadowVdp_ModeReg1
	dc.l	shadowVdp_ModeReg1
	dc.l	shadowVdp_ModeReg2
	dc.l	shadowVdp_ModeReg2
	dc.l	shadowVdp_ModeReg2
	dc.l	shadowVdp_ModeReg3
	dc.l	shadowVdp_ModeReg4

vdpOptionsBits:
	dc.b	$10	;H interrupt
	dc.b	$02	;HV counter
	dc.b	$40	;display
	dc.b	$20	;V interrupt
	dc.b	$10	;DMA
	dc.b	$04	;ext interrupt
	dc.b	$04	;shadows
	even

;init values for vdp
InitVDPValues:
	dc.b	$04,$14,$30,$2C,$07,$5F,$00,$00
	dc.b	$00,$00,$FF,$00,$00,$2E,$00,$01
	dc.b	$11,$00,$02,$00,$00,$00,$00,$80
	even

;	dc.w	$8004,$8114,$8230,$832C,$8407,$855F,$8600,$8700
;	dc.w	$8800,$8900,$8AFF,$8B00,$8C00,$8D2E,$8E00,$8F01
;	dc.w	$9022,$9100,$9200,$9300,$9400,$9500,$9600,$9780

InitVDPColorData:
	dc.w	$0A42,$0222,$0444,$0666,$0888,$0AAA,$0CCC,$0EEE	;white
	dc.w	$0000,$0002,$0004,$0006,$0008,$000A,$000C,$000E	;red
	dc.w	$0000,$0020,$0040,$0060,$0080,$00A0,$00C0,$00E0	;green
	dc.w	$0000,$0200,$0400,$0600,$0800,$0A00,$0C00,$0E00	;blue
	dc.w	$0000,$0022,$0044,$0066,$0088,$00AA,$00CC,$00EE	;yellow
	dc.w	$0000,$0202,$0404,$0606,$0808,$0A0A,$0C0C,$0E0E	;magenta
	dc.w	$0000,$0220,$0440,$0660,$0880,$0AA0,$0CC0,$0EE0	;cyan
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000	;black

;///////////////////////////////////////////////////////////////////////////////
	section	"CODE",code

;---------------------------------------
;VDP_Init
;
;Description
;
;Calling Convention
;
;---------------------------------------
	public	_VDP_Init
_VDP_Init:
	link	a5,#0

	pea	24
	pea	InitVDPValues
	pea	shadowVdp_address
	bsr	_memcpy
	pea	128
	pea	InitVDPColorData
	pea	_colorBuffer
	bsr	_memcpy

	add.w	#24,sp

;set all the colors and VS ram to 0 or whatever they are
	moveq	#0,d0
	move.l	d0,allocVramStart
	move.w	d0,allocVramCurrent
	move.l	d0,allocVramEnd

	unlk	a5
	rts

;---------------------------------------
;VDP_CommitShadowRegisters
;
;Description
;
;Calling Convention
;
;---------------------------------------
	public	_VDP_CommitShadowRegisters
_VDP_CommitShadowRegisters:
	link	a5,#0

	lea	shadowVdp_address,a0
	lea	VDP_CTRL,a1
	move.w	#$8000,d0
	moveq	#24-1,d1
.loop:	move.b	(a0)+,d0
	move.w	d0,(a1)
	add.w	#$0100,d0
	dbra	d1,.loop

	unlk	a5
	rts

;---------------------------------------
;_VDP_Enable
;
;Description
;
;Calling Convention
;	move.l	#ID,-(sp)
;	bsr	_VDP_Enable
;	addq.w	#4,a7
;
;---------------------------------------
	public	_VDP_Enable
;d0 = scratch / index
;d1 = data to bitwise OR with values
;a0 = ram table
;a1 = ram address to modify
_VDP_Enable:
	link	a5,#0

;find out what bit we want to modify, save in a1
	move.l	(8,a5),d0
	cmp.b	#8,d0
	bcs	.valid
	move.l	#UNKNOWN_INPUT,d0
	bra	.exit
.valid:	lea	vdpOptionsBits,a0
	move.b	(a0,d0),d1

;what byte of ram we need to apply the OR to.
	lea	vdpOptionsTable,a0
	asl.b	#2,d0
	move.l	(a0,d0),a1

;d1 = value to OR with
;a1 = address to apply OR to
	or.b	d1,(a1)

;return no error
	moveq	#0,d0

;we are done, we clean our mess
.exit:	unlk	a5
	rts

;---------------------------------------
;_VDP_Disable
;
;Description
;
;Calling Convention
;
;---------------------------------------
	public	_VDP_Disable
_VDP_Disable:
	link	a5,#0

;find out what bit we want to modify, save in a1
	move.l	(8,a5),d0
	cmp.b	#8,d0
	bcs	.valid
	move.l	#UNKNOWN_INPUT,d0
	bra	.exit
.valid:	lea	vdpOptionsBits,a0
	move.b	(a0,d0),d1

;what byte of ram we need to apply the OR to.
	lea	vdpOptionsTable,a0
	asl.b	#2,d0
	move.l	(a0,d0),a1

	not.b	d1
;d1 = value to OR with
;a1 = address to apply OR to
	and.b	d1,(a1)

;return no error
	moveq	#0,d0

.exit:	unlk	a5
	rts

;---------------------------------------
;VDP_SetVideoRegion
;
;Sets the Video settings for NTSC or PAL
;
;	move.l	#region,-(sp)
;	bsr	_VDP_SetVideoRegion
;	addq.w	#4,sp
;
;---------------------------------------
	public	_VDP_SetVideoRegion
_VDP_SetVideoRegion:
	link	a5,#0

	move.l	(8,a5),d0
	lea	shadowVdp_ModeReg2,a0

	tst.l	d0	;AUTO?
	beq	.auto
	cmp.b	#VDP_REGION_NTSC,d0
	beq	.ntsc
	cmp.b	#VDP_REGION_PAL,d0
	beq	.pal

;I don't know what input you gave me but I will just say IDK.
	move.l	#UNKNOWN_INPUT,d0
	bra	.exit

;Just Figure it out ourselves
.auto:	move.w	VDP_CTRL,d0
	btst	#0,d0
	bne	.pal

;North the America's and Japan
.ntsc:	bclr	#3,(a0)
	bra	.exit
;Europe
.pal:	bset	#3,(a0)

;return no error
.exit:	moveq	#0,d0
	unlk	a5
	rts

;---------------------------------------
;VDP_SetScreenWidth
;
;Sets the screen width to 32 or 40
;
;Calling Convention
;
;---------------------------------------
	public	_VDP_SetScreenWidth
_VDP_SetScreenWidth:
	link	a5,#0

;make sure that we get valid input
	move.l	(8,a5),d0
	cmp.b	#3,d0
	bcs	.valid

;I don't know what input you gave me but I will just say IDK.
	move.l	#UNKNOWN_INPUT,d0
	bra	.exit

;set the video setting
.valid:	lea	shadowVdp_ModeReg4,a0
	tst.l	d0
	bne	.Mode40
	bclr	#7,(a0)
	bclr	#0,(a0)
	bra	.skip
.Mode40:
	bset	#7,(a0)
	bset	#0,(a0)
.skip:	moveq	#0,d0
.exit:	unlk	a5
	rts

;---------------------------------------
;VDP_SetHRate
;
;sets the H interrupt rate for the VDP
;68k must be lissoning for them however
;
;Calling Convention
;void	VDP_SetHRate(uint8_t rate);
;
;	move.l	#rate,-(sp)
;	bsr	_VDP_SetHRate
;	addq.w	#4,sp
;---------------------------------------
	public	_VDP_SetHRate
_VDP_SetHRate:
	link	a5,#0
	move.l	(8,a5),d0
	move.b	d0,shadowVdp_HRate
	unlk	a5
	rts

;---------------------------------------
;VDP_BackgroundColorIndex
;
;sets the H interrupt rate for the VDP
;68k must be lissoning for them however
;
;Calling Convention
;error_t	VDP_BackgroundColorIndex(uint8_t index);
;
;	move.l	#index,-(sp)
;	bsr	_VDP_BackgroundColorIndex
;	addq.w	#4,sp
;---------------------------------------
	public	_VDP_BackgroundColorIndex
_VDP_BackgroundColorIndex:
	link	a5,#0
	move.l	(8,a5),d0
	cmp	#64,d0
	bcs	.valid
	moveq	#OUT_OF_BOUNDS,d0
	bra	.exit

.valid:	move.b	d0,shadowVdp_HRate
	moveq	#0,d0
.exit:	unlk	a5
	rts


;---------------------------------------
;VDP_DMAColorBuffer
;
;Description
;
;void	VDP_DMAColorBuffer();
;
;	bsr	VDP_DMAColorBuffer
;
;---------------------------------------
	public	VDP_DMAColorBuffer
VDP_DMAColorBuffer:
	link	a5,#0
	move.l	d2,-(sp)

;set auto inc to 2
;	move.b	#1,shadowVdp_Incr
	lea	VDP_CTRL,a0
	move.w	#$8F02,(a0)

;set length of DMA
	move.w	#$9340,(a0)
	move.w	#$9400,(a0)

;set source of DMA
	move.w	#$9500,d0
	moveq	#3-1,d2
	lea	_colorBuffer,a1
	move.l	a1,d1
	lsr.l	#1,d1
.loop:	move.b	d1,d0
	move.w	d0,(a0)
	lsr.l	#8,d1
	add.w	#$0100,d0
	dbra	d2,.loop

	move.l	#CRAM_DMA_CMD,(a0)
	move.l	(sp)+,d2
	unlk	a5
	rts

;---------------------------------------
;VDP_DMAVSRAMBuffer
;
;void	VDP_DMAVSRAMBuffer();
;
;	bsr	VDP_DMAVSRAMBuffer
;
;---------------------------------------
	public	VDP_DMAVSRAMBuffer
VDP_DMAVSRAMBuffer:
	link	a5,#0
	move.l	d2,-(sp)

;set auto inc to 2
;	move.b	#1,shadowVdp_Incr
	lea	VDP_CTRL,a0
	move.w	#$8F02,(a0)

;set length of DMA
	move.w	#$9328,(a0)
	move.w	#$9400,(a0)

;set source of DMA
	move.w	#$9500,d0
	moveq	#3-1,d2
	lea	_VSRamBuffer,a1
	move.l	a1,d1
	lsr.l	#1,d1
.loop:	move.b	d1,d0
	move.w	d0,(a0)
	lsr.l	#8,d1
	add.w	#$0100,d0
	dbra	d2,.loop

	move.l	#VSRAM_DMA_CMD,(a0)
	move.l	(sp)+,d2
	unlk	a5
	rts

;---------------------------------------
;VDP_DMASpriteBuffer
;
;void	VDP_DMAVSRAMBuffer();
;
;	bsr	VDP_DMASpriteBuffer
;
;---------------------------------------
	public	VDP_DMASpriteBuffer
VDP_DMASpriteBuffer:
	link	a5,#0
	move.l	d2,-(sp)

;set auto inc to 2
;	move.b	#1,shadowVdp_Incr
	lea	VDP_CTRL,a0
	move.w	#$8F02,(a0)

;set length of DMA
	move.w	#$9380,(a0)
	move.w	#$9400,(a0)

;set source of DMA
	move.w	#$9500,d0
	moveq	#3-1,d2
	lea	_objectDefinition,a1
	move.l	a1,d1
	lsr.l	#1,d1
.loop:	move.b	d1,d0
	move.w	d0,(a0)
	lsr.l	#8,d1
	add.w	#$0100,d0
	dbra	d2,.loop


	move.l	#VRAM_DMA_CMD,-(sp)
	move.l	#$BE00,-(sp)
	bsr	_VDP_WriteCommand
	addq.w	#8,sp

	move.l	d0,(a0)
	move.l	(sp)+,d2
	unlk	a5
	rts

;---------------------------------------
;VDP_CommitColorBuffer
;
;Description
;
;Calling Convention
;void	VDP_CommitColorBuffer();
;	bsr	VDP_CommitColorBuffer
;---------------------------------------
	public	_VDP_CommitColorBuffer
_VDP_CommitColorBuffer:
	subq.b	#1,vdpCommitColorBufferFlag
	rts

;---------------------------------------
;VDP_CommitVSRAMBuffer
;
;Description
;
;Calling Convention
;void	VDP_CommitVSRAMBuffer()
;	bsr	VDP_CommitVSRAMBuffer
;---------------------------------------
	public	_VDP_CommitVSRAMBuffer
_VDP_CommitVSRAMBuffer:
	subq.b	#1,vdpCommitVSRAMBufferFlag
	rts

;---------------------------------------
;VDP_CommitVSRAMBuffer
;
;Description
;
;Calling Convention
;void	VDP_CommitVSRAMBuffer()
;	bsr	VDP_CommitVSRAMBuffer
;---------------------------------------
	public	_VDP_CommitSpriteBuffer
_VDP_CommitSpriteBuffer:
	subq.b	#1,vdpCommitSpriteBufferFlag
	rts

;---------------------------------------
;VDP_StartCPUHandshake
;
;Start's interrupts on the VDP and
;68k, will stop the cpu and wait.
;this is also the time where all the
;shadow registers are committed to the
;CPU
;
;Calling Convention
;void	VDP_StartCPUHandshake();
;	bsr	_VDP_StartCPUHandshake
;---------------------------------------
	public	_VDP_StartCPUHandshake
_VDP_StartCPUHandshake:
;	link	a5,#0
	move.w	#$8134,(VDP_CTRL)
	stop	#$2500
;	unlk	a5
	rts

;---------------------------------------
;_VDP_WriteCommand
;
;Description
;
;Calling Convention
;void	VDP_WriteCommand(uint16_t address, VDPCmd_t command);
;
;	move.l	#command,-(sp)
;	move.l	#address,-(sp)
;	bsr	_VDP_WriteCommand
;	addq.w	#8,sp
;---------------------------------------
	public	_VDP_WriteCommand
_VDP_WriteCommand:
	link	a5,#0
	move.l	(8,a5),d0	;addr
	and.l	#$FFFF,d0
	lsl.l	#2,d0
	lsr.w	#2,d0
	swap	d0
	or.l	(12,a5),d0	;cmd
	unlk	a5
	rts

;---------------------------------------
;VDP_AllocMoreTiles
;
;allocates more tiles for the linked list
;
;Calling Convention
;	move.l	#numTiles, -(sp)
;	bsr	VDP_AllocMoreTiles
;
;returns:
;pointer to allocated struct or null
;
;---------------------------------------
VDP_AllocMoreTiles:
	link	a5,#0

	move.l	d2,-(sp)

	move.l	(8,a5),d2
	tst.l	d2	;allocating 0 tiles?
	beq	.exit	;yes: then wth are you doing?
	move.l	d2,d0

;check to see if we will run out of tiles
	add.w	allocVramCurrent,d0
	cmp.w	#VRAM_MAX_NUMTILES,d0	;will we blow our tile limit?
	bls	.ok	;no: continue
	moveq	#0,d0	;yes: then we don't bother trying anything else
	bra	.exit	;and return null
.ok:

;we have enough tiles to allocate
;allocate a new node in the list
	pea	8
	bsr	_malloc
	addq.w	#4,sp
	tst.l	d0	;did that fail?
	beq	.exit	;yes: now we have a problem

;no: start filling out the struct
	move.l	d0,a0
	move.w	#-1,(VRAM_ALLOC_FREE,a0)

;need to turn this into a physical VRAM address
	move.w	allocVramCurrent,d0
	asl.w	#5,d0
	move.w	d0,(VRAM_ALLOC_VRAM,a0)

	move.w	#0,(VRAM_ALLOC_NEXT,a0)
	move.w	d2,(VRAM_ALLOC_NUM,a0)

;advance the allocated tiles
	add.w	d2,allocVramCurrent

;move to return register
	move.l	a0,d0

.exit:	move.l	(sp)+,d2
	unlk	a5
	rts

;---------------------------------------
;VSP_SearchForFreeTiles
;
;looks for free tiles in video memory
;
;Calling Convention
;	move.l	#numTiles, -(sp)
;	bsr	VSP_SearchForFreeTiles
;	addq.w	#4
;---------------------------------------
;a0 = previous node
;a1 = this node
;a2 = new node if needed
;
;
;d2 = number of tiles requested

VDP_SearchForFreeTiles:
	link	a5,#0
	movem.l	d2/a2-a3,-(sp)

;number of tiles requested
	move.l	(8,a5),d2

;start at the beginning of the list
	move.l	allocVramStart,a2

;is have we reached the end of the block?
.loop:	move.w	a2,d0
	tst.w	d0
	beq	.NoMoreNodes

	tst.w	(VRAM_ALLOC_FREE,a2)	;is this block free?
	bne	.nodeNotUsable		;no: move onto the next block.
	cmp	(VRAM_ALLOC_NUM,a2),d2	;yes: is it enough tiles?
	bhi	.nodeNotUsable		;no: move onto the next block

;check for any extra tiles
	move.w	(VRAM_ALLOC_NUM,a2),d0
	sub.w	d2,d0		;got any leftover tiles?
	beq	.exactNumTiles	;no: no need to break down

;TODO: break down the node into 2, one exact, the other the remainder
;d0 = number of extra tiles
	move.w	d2,(VRAM_ALLOC_NUM,a2)
	move.l	d0,-(sp)

;make a new node
	pea	8
	bsr	_malloc
	addq.w	#4,sp
	move.l	d0,a3
	tst.l	d0	;did that fail?
	beq	.exactNumTiles	;just return the block that we found

;VRAM_ALLOC_FREE equ 0
;VRAM_ALLOC_VRAM equ 2
;VRAM_ALLOC_NUM equ 4
;VRAM_ALLOC_NEXT equ 6

	move.w	#0,(VRAM_ALLOC_FREE,a3)		;mark new node as free
	move.l	(sp)+,d1
	move.w	d1,(VRAM_ALLOC_NUM,a3)		;number of remaining tiles

;calculate final vram offset
;free tiles offset


	move.w	(VRAM_ALLOC_VRAM,a2),d1		;address
	move.w	d1,(VRAM_ALLOC_VRAM,a3)
	move.w	(VRAM_ALLOC_NUM,a2),d1
	asl.w	#5,d1
	add.w	d1,(VRAM_ALLOC_VRAM,a3)
;take the number of tiles on the previous node and calculate the start pos
;in vram

;new.next = this.next
;this.next = new
	move.w	(VRAM_ALLOC_NEXT,a2),d1
	move.w	d1,(VRAM_ALLOC_NEXT,a3)
	move.w	a3,(VRAM_ALLOC_NEXT,a2)


.exactNumTiles:
	move.l	a2,d0	;return this node
	bra	.exit
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;we get here when we need to goto the next node
.nodeNotUsable:
	move.w	(VRAM_ALLOC_NEXT,a2),a2
	bra	.loop

.NoMoreNodes:
	moveq	#0,d0
.exit:	movem.l	(sp)+,d2/a2-a3
	unlk	a5
	rts

;---------------------------------------
;VDP_AllocVram
;
;Description:
;attempts to find space in vram to reserve
;for any purpose. I.E sprites and backgrounds
;
;Calling Convention
;uint8_t* VDP_AllocateVram(uint8_t numTiles);
;
;	pea	numTiles
;	bsr	_VDP_AllocateVram
;
;---------------------------------------
;d2 = requested size

;VRAM_ALLOC_FREE equ 0
;VRAM_ALLOC_VRAM equ 2
;VRAM_ALLOC_NUM equ 4
;VRAM_ALLOC_NEXT equ 6

;allocVramStart	ds.l	1
;allocVramEnd	ds.l	1
;allocVramCurrent ds.w	1

	public	_VDP_AllocVram
_VDP_AllocVram:
	link	a5,#0

;search for any free tiles
	move.l	(8,a5),d0
	move.l	d0,-(sp)
	bsr	VDP_SearchForFreeTiles
	addq.w	#4,sp
	tst.l	d0		;found any?
	beq	.noFreeTiles	;no: allocate more

;yes: reserve the node and return it
	move.l	d0,a0
	move.w	#-1,(VRAM_ALLOC_FREE,a0)
	bra	.exit

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.noFreeTiles:
;allocate more tiles in video memory
	move.l	(8,a5),d0
	move.l	d0,-(sp)
	bsr	VDP_AllocMoreTiles
	addq.w	#4,sp
	tst.l	d0	;did that fail?
	beq	.exit	;yes: well return null then


	tst.l	allocVramStart	;is this the 1st time calling this?
	bne	.notFirst	;no: no need to set the head of the linked list
	move.l	d0,allocVramStart	;yes: make this node the head
	move.l	d0,allocVramEnd		;also make this the end
	bra	.exit

;link to the end of the list and point allocVramEnd to it
.notFirst:
	move.l	d0,a0
	move.l	allocVramEnd,a1
	move.w	a0,(VRAM_ALLOC_NEXT,a1)
	move.l	a0,allocVramEnd

.exit:	unlk	a5
	rts

;---------------------------------------
;_VDP_FreeVram
;
;takes a pointer to a VDPVramNode_t
;and frees the tiles, combining them
;with other blocks if nessesary
;
;Calling Convention
;	move.l	node, -(sp)
;	bsr	_VDP_FreeVram
;	addq.w	#4,sp
;
;VDP_FreeVram(VDPVramNode_t* node);
;---------------------------------------
;a0 =  this block

	public	_VDP_FreeVram
_VDP_FreeVram:
	link	a5,#0

	move.l	(8,a5),a0

;free the block of tiles
	move.w	#0,(VRAM_ALLOC_FREE,a0)

;VRAM_ALLOC_FREE equ 0
;VRAM_ALLOC_VRAM equ 2
;VRAM_ALLOC_NUM equ 4
;VRAM_ALLOC_NEXT equ 6

;try to concatinate block together
;a0 = this block
;a1 = next block
	move.l	allocVramStart,a0
.loop:	move.w	a0,d0
	tst.w	d0	;is this block null?
	beq	.exit	;yes: no need to go any more
	tst.w	(VRAM_ALLOC_FREE,a0)	;is this block free?
	bne	.blockNotFree		;no: skip to next

	move.w	(VRAM_ALLOC_NEXT,a0),a1	;yes: grab the next block
	cmp.w	#0,a1	;is it null?
	beq	.noNext	;yes: at the end of the list

	tst.w	(VRAM_ALLOC_FREE,a1)	;is the next block free?
	bne	.blockNotFree

;we get here when this block and the next block are free, concatinate
	move.w	(VRAM_ALLOC_NUM,a1),d0
	add.w	d0,(VRAM_ALLOC_NUM,a0)
	move.w	(VRAM_ALLOC_NEXT,a1),d0
	move.w	d0,(VRAM_ALLOC_NEXT,a0)

;a1 now needs to be destroyed
	move.l	a1,-(sp)
	bsr	_free
	addq.w	#4,sp

.blockNotFree:
	move.w	(VRAM_ALLOC_NEXT,a0),a0
	bra	.loop

.noNext:

.exit:	unlk	a5
	rts

;---------------------------------------
;Function Name
;
;Description
;
;Calling Convention
;
;---------------------------------------
