;===============================================================================
;init.asm
;===============================================================================
;
;-------------------------------------------------------------------------------

	include "vdpAbstraction.inc"

;///////////////////////////////////////////////////////////////////////////////
	section	"BSS",bss
	public	_errno
_errno	ds.l	1
;///////////////////////////////////////////////////////////////////////////////
	section	"DATA",data

vdpInitRegisters:
	dc.w	$8114,$8F01,$9300,$9400,$9500,$9600,$9780

;///////////////////////////////////////////////////////////////////////////////
	section	"CODE",code

;---------------------------------------
;init
;
;sets up the sega genesis hardware
;
;Calling Convention:
;	bsr	_init
;---------------------------------------
	public	_initSegaGenesis
_initSegaGenesis:

;security system
	move.b	$A10001,d0
	andi.b	#$0F,d0		;is TMSS available?
	beq	.noTmss		;No: no need to write
	move.l	#'SEGA',$A14000	;Yes: Write 'SEGA' to TMSS to disable it
.noTmss:

;start vdp DMA to clear Vram

	lea	VDP_CTRL,a1

;set VDP to known state, I.E flush any buffers
	tst.w	(a1)

;we don't have a method to do this, so I just bake it in her
	lea	vdpInitRegisters,a0
	moveq	#7,d0
	bra	.entrA
.loopA:	move.w	(a0)+,(a1)
.entrA:	dbra	d0,.loopA

	move.l	#VRAM_DMA_CMD,(a1)
	move.w	#0,(VDP_DATA)	;what byte to fill with

;clear first 32k of ram
	move.l	#$00FF0000,a0
	move.l	#$07ff,d0
.loopB:	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	dbra	d0,.loopB

;wait for the DMA to finish before we start using the VDP again
.loopC:	move.w	(a1),d0		;read VDP status
	btst	#1,d0		;dma finished?
	bne	.loopC		;no: continue

;init the VDP
	bsr	_VDP_Init

;init the heap
	bsr	initHeap

;init filesystem
	bsr	_InitFileSystem

;init DMA
	bsr	_DMA_Init

;init controllers
	bsr	_initControllers

;pause the Z80
	move.w	#0,($00A11100)

	rts

;---------------------------------------
;Function Name
;
;Description
;
;Calling Convention
;
;---------------------------------------
