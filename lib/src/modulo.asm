;===============================================================================
;modulo.asm
;===============================================================================
;because this '%' is not defined in vbcc68k, must write it myself
;
;Had to pull out the C99 definition:
;
;https://stackoverflow.com/questions/11720656/modulo-operation-with-negative-numbers
;
;C99 requires that when a/b is representable:
l
;(a/b) * b + a%b shall equal a
;This makes sense, logically. Right?
;Let's see what this leads to:
;Example A. 5/(-3) is -1 => (-1) * (-3) + 5%(-3) = 5
;This can only happen if 5%(-3) is 2.
;Example B. (-5)/3 is -1 => (-1) * 3 + (-5)%3 = -5
;This can only happen if (-5)%3 is -2
;
;-------------------------------------------------------------------------------

;///////////////////////////////////////////////////////////////////////////////
	section	"BSS",bss
;///////////////////////////////////////////////////////////////////////////////
	section	"DATA",data
;///////////////////////////////////////////////////////////////////////////////
	section	"CODE",code

;---------------------------------------
;__lmodu
;
;modulo operator, this is ment to be used by C expressions and not to
;be called explicitly
;
;Calling Convention:
;---------------------------------------

;	(clock % 7);
;	move.l	#7,-(a7)
;	move.l	_clock,-(a7)
;	jsr	__lmodu
;	addq.w	#8,a7

	public	__lmodu
	public __lmods
__lmodu:
__lmods:
	link	a5,#0
	move.l	(8,a5),d0
	move.l	(12,a5),d1
	divs	d1,d0
	swap	d0
	and.l	#$0000FFFF,d0
	unlk	a5
	rts

;---------------------------------------
;Function Name
;
;Description
;
;Calling Convention
;
;---------------------------------------
