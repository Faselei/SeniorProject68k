;===============================================================================
;CartHeader.asm
;===============================================================================
;512 byte cartridge header
;the 1st 256 bytes of a 68k program is the vector table
;the 2nd 256 bytes is the sega genesis / mega drive cart header
;-------------------------------------------------------------------------------

superStackSize equ $0FF0

superStackStart	equ	superStack+superStackSize
;///////////////////////////////////////////////////////////////////////////////
	section	"STACK",bss
superStack ds.b	superStackSize
;///////////////////////////////////////////////////////////////////////////////
	section "HEADER",code
;---------------------------------------
;68k Vector Table
;---------------------------------------
;	dc.l	$00FFFFF0	;starting stack pointer
	dc.l	superStackStart	;starting stack pointer
	dc.l	_main		;starting Program counter
	dc.l	TempVector	;bus error
	dc.l	TempVector	;address Error
	dc.l	TempVector	;Illegal instruction
	dc.l	TempVector	;division by zero
	dc.l	TempVector	;CHK exception
	dc.l	TempVector	;TRAPV exception
	dc.l	TempVector	;Privilage violation
	dc.l	TempVector	;TRACE exception
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;reserved
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;Uninitialized Interrupt
	dc.l	TempVector	;reserved
	dc.l	TempVector	;reserved
	dc.l	TempVector	;reserved
	dc.l	TempVector	;reserved
	dc.l	TempVector	;reserved
	dc.l	TempVector	;reserved
	dc.l	TempVector	;reserved
	dc.l	TempVector	;reserved
	dc.l	TempVector	;Spurious Interrupt
	dc.l	TempVector	;IRQ level 1
	dc.l	TempVector	;IRQ level 2 (EXT Interrupt)
	dc.l	TempVector	;IRQ level 3
	dc.l	TempVector	;IRQ level 4 (VDP Horizontal Interrupt)
	dc.l	TempVector	;IRQ level 5
	dc.l	v_interrupt	;IRQ level 6 (VDP Vertical Interrupt)
	dc.l	TempVector	;IRQ level 7
	dc.l	TempVector	;TRAP #00
	dc.l	TempVector	;TRAP #01
	dc.l	TempVector	;TRAP #02
	dc.l	TempVector	;TRAP #03
	dc.l	TempVector	;TRAP #04
	dc.l	TempVector	;TRAP #05
	dc.l	TempVector	;TRAP #06
	dc.l	TempVector	;TRAP #07
	dc.l	TempVector	;TRAP #08
	dc.l	TempVector	;TRAP #09
	dc.l	TempVector	;TRAP #10
	dc.l	TempVector	;TRAP #11
	dc.l	TempVector	;TRAP #12
	dc.l	TempVector	;TRAP #13
	dc.l	TempVector	;TRAP #14
	dc.l	TempVector	;TRAP #15
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;irrelevant on genesis
	dc.l	TempVector	;reserved
	dc.l	TempVector	;reserved
	dc.l	TempVector	;reserved
	dc.l	TempVector	;reserved
	dc.l	TempVector	;reserved

;---------------------------------------
;Sega Mega Drive / Genesis cart header
;---------------------------------------

	dc.b	"SEGA GENESIS    "
	dc.b	"(C)SEGA 2021.NOV"
	dc.b	"GameName                                        "
	dc.b	"0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF"
	dc.b	"GM XXXXXXXX-XX"
	dc.w	$0000
	dc.b	"J               "
	dc.l	$00000000,$001FFFFF
	dc.l	$00FF0000,$00FFFFFF
	dc.b	"                      "
;		"					   "
	dc.b	"Library cart header                       "	;memo
	dc.b	"JUE             "

;///////////////////////////////////////////////////////////////////////////////
	section "CODE",code

;---------------------------------------
;VBlank
;---------------------------------------
TempVector:
	nop
	nop
	bra	TempVector
	rte
