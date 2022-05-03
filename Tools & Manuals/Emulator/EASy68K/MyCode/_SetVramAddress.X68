*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

;VDP_SCROLL_A equ $C000
;VDP_WINDOW equ $B000
;VDP_SCROLL_B equ $E000
;$5F sprite equ $BE00
;$2E hscroll equ $B800

    move.l  #$C000,-(a7)    ;shadowVdp_PlaneA
    move.l  #0,-(a7)
    bsr _SetVramAddress
    moveq   #0,d0
    add.w   #8,a7
    
    move.l  #$E000,-(a7)    ;shadowVdp_PlaneB
    move.l  #1,-(a7)
    bsr _SetVramAddress
    moveq   #0,d0
    add.w   #8,a7
    
    move.l  #$B000,-(a7)    ;shadowVdp_Window
    move.l  #2,-(a7)
    bsr _SetVramAddress
    moveq   #0,d0
    add.w   #8,a7
    
    move.l  #$BE00,-(a7)    ;shadowVdp_Sprite
    move.l  #3,-(a7)
    bsr _SetVramAddress
    moveq   #0,d0
    add.w   #8,a7
    
    move.l  #$B800,-(a7)    ;shadowVdp_HScroll
    move.l  #4,-(a7)
    bsr _SetVramAddress
    moveq   #0,d0
    add.w   #8,a7

* Put program code here
    SIMHALT             ; halt simulator
    
    
VramAddressFilterTable:
    dc.b    $02 ;additional number of shifts    ;PlaneA
    dc.b    $34 ;input is bitwise AND with this ;
    
    dc.b    $05 ;PlaneB
    dc.b    $07
    
    dc.b    $02 ;Window
    dc.b    $3E
    
    dc.b    $01 ;Sprite
    dc.b    $7f
    
    dc.b    $02 ;HScroll
    dc.b    $3f

VramAddressVariableTable:
    dc.l    shadowVdp_PlaneA
    dc.l    shadowVdp_PlaneB
    dc.l    shadowVdp_Window
    dc.l    shadowVdp_Sprite
    dc.l    shadowVdp_HScroll

    
;---------------------------------------
;
;void SetVramAddress(command. address)
;	move.l	#address,-(a7)
;	move.l	#command,-(a7)
;	bsr	_SetVramAddress
;	add.w	#4,a7
;---------------------------------------
;d0 = index
;d1 = scratch value
;a0 = address of AND & shifts table
;a1 = address of ram we are modifying

_SetVramAddress:
    link    a5,#0
    move.l  (8,a5),d0   ;command
    move.l  (12,a5),d1  ;address

;find out what byte we are about to modify, and the logic and Bit shifts to go with it
    lea VramAddressFilterTable,a0
    lea VramAddressVariableTable,a1   
    lsl.b   #2,d0
    move.l	(a1,d0),a1
    lsr.b   #1,d0
    lea  (a0,d0),a0
    
;start by shifting the high 8 bytes to the lower 8
    lsr.l   #8,d1
    move.b  (a0)+,d0    ;can't do the next instruction in 1 step
    lsr.l   d0,d1       ;shift the extra amount
    and.b   (a0)+,d1    ;bitwise and with this
    move.b  d1,(a1)     ;store result
    unlk    a5
    rts

* Put variables and constants here
    org $00FF0000

shadowVdp_PlaneA    ds.b    1
shadowVdp_PlaneB    ds.b    1
shadowVdp_Window    ds.b    1
shadowVdp_Sprite    ds.b    1
shadowVdp_HScroll   ds.b    1

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
