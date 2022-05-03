*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------


VDP_SCROLL_SIZE equ 0
VDP_VIRTICAL_SCROLL equ 1
VDP_HORIZONTAL_SCROLL equ 2
VDP_WINDOW_HPOS equ 3
VDP_WINDOW_VPOS equ 4


    ORG    $1000
    
SetNameTableConfigData:
;Scroll size
;Virtical scroll mode
;Horizontal scroll mode
;Window H position
;Window V position
    even

SetNameTableConfigRam:
    even
    
START:                  ; first instruction of program

* Put program code here

;void SetVramAddress(option, flag)
	move.l	#flag,-(a7)
	move.l	#option,-(a7)
	bsr	_SetNameTableConfig
	moveq	#0,d0
	add.w	#8,a7
    SIMHALT             ; halt simulator
    
_SetNameTableConfig:
    link    a5,#0
    
    move.l	(8,a5),d0	;input option
    lea SetNameTableConfigData,a0
    lea SetNameTableConfigRam,a1
    
    unlk    a5
    rts

* Put variables and constants here
    org $00FF0000
shadowVdp_Size ds.b 1
shadowVdp_WinX ds.b 1
shadowVdp_WinY ds.b 1
	even
    
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
