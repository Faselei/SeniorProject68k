;===============================================================================
;dma_a.asm
;===============================================================================
;this is the assembly based queue processor for DMA,
;things that polulate that array are defined in DMA.c
;-------------------------------------------------------------------------------

	include	"vdpAbstraction.inc"

;queue notes
;dmaType	ds.l	1
;length		ds.w	1
;dmaStart	ds.l	1
;dmaSource	ds.l	1
;14 bytes
;///////////////////////////////////////////////////////////////////////////////
	section	"BSS",bss
buffer	ds.w 6
;///////////////////////////////////////////////////////////////////////////////
	section	"DATA",data
;///////////////////////////////////////////////////////////////////////////////
	section	"CODE",code

;---------------------------------------
;_DMA_ProcessQueue
;
;takes the array _queueIndex and feeds
;it to the DMA unit
;
;Calling Convention
;	bsr	_DMA_ProcessQueue
; or
;	DMA_ProcessQueue();
;---------------------------------------
;a0 = table address
;a1 = VDP_CTRL
;a2 = movep buffer
;d0 = scratch
;d1 = counter

	public	_DMA_ProcessQueue
_DMA_ProcessQueue:
	link	a5,#0

	move.l	a2,-(sp)	;might use A2

	lea	_queueArea,a0	;start at the beginning
	lea	VDP_CTRL,a1	;we will be using this a lot
	lea	buffer,a2	;buffer for movep instruction
	moveq	#0,d1		;and the first element
	move.b	_queueIndex,d1
	bra	.enter
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.loop:	move.l	(a0)+,d0
	tst.l	d0		;memory to vdp?
	bne	.notMain	;no: check dma fill

;hacked in direction
	move.w	#$8F00,d0
	add.b	(a0)+,d0
	addq.l	#1,a0
	move.w	d0,(a1)

;	move.w	#$8F02,(a1)	;every word
;	addq.l	#2,a0

	move.l	(a0)+,-(sp)	;we need to write this 4 bytes last

	move.w	#$9493,d0	;dma size vdp registers
	movep.w	d0,0(a2)	;write it
	move.w	(a0)+,d0	;size value
	movep.w	d0,1(a2)	;write it

	move.l	#$00979695,d0	;dma source vdp registers
	movep.l	d0,4(a2)
	move.l	(a0)+,d0	;23 bit address as 32 bit value
	movep.l	d0,5(a2)

;pipe all the data to the DMA VDP registers
	move.w	(a2),(a1)	;size high
	move.w	(2,a2),(a1)	;size low
	move.w	(6,a2),(a1)	;source high
	move.w	(8,a2),(a1)	;source mid
	move.w	(10,a2),(a1)	;source low

;Start the dma's
	move.l	(sp)+,(a1)	;start the DMA

	bra	.enter		;skip spin check
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.notMain:
	cmpi	#1,d0		;fill?
	bne	.notFill	;no: check copy


;hacked in direction
	move.w	#$8F00,d0
	add.b	(a0)+,d0
	addq.l	#1,a0
	move.w	d0,(a1)

;	move.w	#$8F01,(a1)	;every byte
;	addq.l	#2,a0

	move.l	(a0)+,-(sp)	;we need to write this 4 bytes last

	move.w	#$9493,d0	;dma size vdp registers
	movep.w	d0,0(a2)	;write it
	move.w	(a0)+,d0	;size value
	movep.w	d0,1(a2)	;write it

;pipe all the data to the DMA VDP registers
	move.w	(a2),(a1)	;size high
	move.w	(2,a2),(a1)	;size low

	move.w	#$9780,(a1)

;Start the dma's
	move.l	(sp)+,(a1)	;start the DMA
	move.b	(a0)+,(VDP_DATA)	;write the value to fill with

;skip the unused bytes in the union
	addq.l	#3,a0

	bra	.spin	;wait for the DMA to complete before loading next
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.notFill:
	cmpi	#2,d0	;copy?
	bne	.enter	;no: just skip it


;hacked in direction
	move.w	#$8F00,d0
	add.b	(a0)+,d0
	addq.l	#1,a0
	move.w	d0,(a1)

;	move.w	#$8F01,(a1)	;every byte
;	addq.l	#2,a0

	move.l	(a0)+,-(sp)	;we need to write this 4 bytes last

	move.w	#$9493,d0	;dma size vdp registers
	movep.w	d0,0(a2)	;write it
	move.w	(a0)+,d0	;size value
	movep.w	d0,1(a2)	;write it

	move.w	#$9695,d0	;dma size vdp registers
	movep.w	d0,4(a2)	;write it
	move.w	(a0)+,d0	;size value
	movep.w	d0,5(a2)	;write it

;pipe all the data to the DMA VDP registers
	move.w	(a2),(a1)	;size high
	move.w	(2,a2),(a1)	;size low
	move.w	(4,a2),(a1)	;vram high
	move.w	(6,a2),(a1)	;vram low

	move.w	#$97C0,(a1)

;Start the dma's
	move.l	(sp)+,(a1)	;start the DMA
;	move.w	(a0)+,(VDP_DATA)	;where are we starting at

;skip the unused bytes in the union
	addq.l	#2,a0

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;wait for the DMA to finish before we start using the VDP again
.spin:	move.w	(a1),d0		;read VDP status
	btst	#1,d0		;dma finished?
	bne	.spin		;no: continue

.enter:	dbra	d1,.loop

;reset queue index
	move.b	#0,_queueIndex

	move.l	(sp)+,a2
	unlk	a5
	rts

;---------------------------------------
;_DMA_Init
;
;call this once to make sure boolean is false
;
;Calling Convention
;
;---------------------------------------
	public	_DMA_Init
_DMA_Init:
	move.b	#0,_processDMAQueue
	move.b	#0,_queueIndex
	rts

;---------------------------------------
;Function Name
;
;Description
;
;Calling Convention
;
;---------------------------------------
