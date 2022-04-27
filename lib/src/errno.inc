;===============================================================================
;errno.inc
;===============================================================================
;Defines the error codes for things supporting it, should be the same as in
;errno.h
;-------------------------------------------------------------------------------

NONE equ 0
FILE_NOT_FOUND equ 1
DOES_NOT_EXIST equ 2
BAD_ADDRESS equ 3
IO_ERROR equ 4
DEADLOCK equ 5
TOO_LONG equ 6
OUT_OF_MEMORY equ 7
OUT_OF_BOUNDS equ 8
UNKNOWN_INPUT equ 9

;///////////////////////////////////////////////////////////////////////////////
	section	"BSS",bss

;	public	_errno
;_errno	ds.l	1

;///////////////////////////////////////////////////////////////////////////////

