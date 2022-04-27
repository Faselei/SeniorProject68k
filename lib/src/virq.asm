;===============================================================================
;virq.asm
;===============================================================================
;virtucal blank IRQ, happens at 60hz (NTSC) or 50hz (PAL)
;this is the only constant source of time on the system that does not require
;some wizard to work with us.
;-------------------------------------------------------------------------------

	include "vdpAbstraction.inc"

;///////////////////////////////////////////////////////////////////////////////
	section	"BSS",bss
	public	_clock
_clock	ds.l	1

virqSavedReg	ds.l	15


;///////////////////////////////////////////////////////////////////////////////
	section	"DATA",data
;///////////////////////////////////////////////////////////////////////////////
	section	"CODE",code

;---------------------------------------
;Function Name
;
;Description
;
;Calling Convention
;
;---------------------------------------
	public	v_interrupt
v_interrupt:

;push all registers
	movem.l	d0-d7/a0-a6,virqSavedReg

;refresh VDP
	tst.w	(VDP_CTRL)

;DMA colors?
	tst.b	(vdpCommitColorBufferFlag)
	beq	.noColorDMA
	bsr	VDP_DMAColorBuffer
	move.b	#0,vdpCommitColorBufferFlag
.noColorDMA:

;DMA vsram?
	tst.b	(vdpCommitVSRAMBufferFlag)
	beq	.noVSRAMDAM
	bsr	VDP_DMAVSRAMBuffer
	move.b	#0,vdpCommitVSRAMBufferFlag
.noVSRAMDAM:

;DMA sprite buffer?
	tst.b	(vdpCommitSpriteBufferFlag)
	beq	.noSpriteDMA
	bsr	VDP_DMASpriteBuffer
	move.b	#0,vdpCommitSpriteBufferFlag
.noSpriteDMA:

;Anything in the DMA queue?
	tst.b	_processDMAQueue	; == 0: NO, != 0: YES
	beq	.noDMA			;No: skip
	bsr	_DMA_ProcessQueue	;Yes: do them
	move.b	#0,_processDMAQueue	;then set to false
.noDMA:

;commit shadow registers
	bsr	_VDP_CommitShadowRegisters

;commit horizontal scrolling register
	move.l	#VRAM_WRITE_CMD,-(sp)
	move.l	#$0000B800,-(sp)
	bsr	_VDP_WriteCommand
	addq.w	#8,sp
	move.l	d0,(VDP_CTRL)
	move.w	_hScroll,d0
	neg	d0
	move.w	d0,(VDP_DATA)

;update controllers
	bsr	_updateControllerInputs


;mark that time has passed
	add.l	#1,_clock

;restore all registers and return
	movem.l	virqSavedReg,d0-d7/a0-a6
	rte


;---------------------------------------
;Function Name
;
;Description
;
;Calling Convention
;
;---------------------------------------
