*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

VDP_SCROLL_32x32 equ 0
VDP_SCROLL_32x64 equ 1
VDP_SCROLL_64x32 equ 2
VDP_SCROLL_64x64 equ 3
VDP_SCROLL_128x32 equ 4
VDP_SCROLL_32x128 equ 5

    ORG    $1000
    
SetNametableModeData:
    dc.b    $00 ;32x32
    dc.b    $01 ;32x64
    dc.b    $10 ;64x32
    dc.b    $11 ;64x64
    dc.b    $30 ;128x32
    dc.b    $03 ;32x128
    
START:                  ; first instruction of program

* Put program code here

;void SetScrollingMode(option)
	move.l	#VDP_SCROLL_32x32,-(a7)
	bsr	_SetScrollingMode
	moveq	#0,d0
	add.w	#4,a7	
    SIMHALT             ; halt simulator
    
_SetnametableMode:
    link    a5,#0
    
    move.l	(8,a5),d0	;input option
    lea SetScrollingModeData,a0
    lea shadowVdp_Size,a1
    move.b  (a0,d0),(a1)
    
    unlk    a5
    rts

* Put variables and constants here
    org $00FF0000
shadowVdp_Size ds.b 1
	ds.b 1
    
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
