*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    pea ' '
    pea Strings
    bsr _strtok
    addq.w  #8,sp
    
    pea ' '
    pea 0
    bsr _strtok
    addq.w  #8,sp
    
    pea ' '
    pea 0
    bsr _strtok
    addq.w  #8,sp
    
    pea ' '
    pea 0
    bsr _strtok
    addq.w  #8,sp
    
    pea ' '
    pea 0
    bsr _strtok
    addq.w  #8,sp
    
    pea ' '
    pea 0
    bsr _strtok
    addq.w  #8,sp


    SIMHALT             ; halt simulator
;---------------------------------------
;   copy string 1 to string 2
;
;   pea string 1
;   pea string 2
;   bsr _strcpy
;   addq.w  #8,sp
;---------------------------------------
_strcpy:
    link    a5,#0
    
    movem.l   a2-a3,-(sp)
    
    move.l  (8,a5),a3
    move.l  (12,a5),a2
    
;find out the length of the string
    move.l  a2,-(sp)
    bsr _strlen
    addq.w  #4,sp
.loop:
    move.b  (a2)+,(a3)+
    dbra    d0,.loop
    
    movem.l   (sp)+,a2-a3
    unlk    a5
    rts
    
;---------------------------------------
; finds the length of a zero terminated
; string
;
;   pea string
;   bsr _strlen
;   addq.w  #4,sp
;---------------------------------------
_strlen:
    link    a5,#0
    
;load the string
    move.l  (8,a5),a0
    moveq   #0,d0
.loop:
    tst.b   (a0)+
    beq .exit
    addq.l  #1,d0
    bra .loop
.exit:
    unlk    a5
    rts
    
;---------------------------------------
;_strtok
;
;breaks string str into a series of
;tokens using the delimiter delim.
;
;passing NULL (0) as the string continues
;from the last string passed to it.
;
;   pea delim
;   pea string
;   bsr _strtok
;   addq.w  #8,sp
;---------------------------------------
;a0 = string to process
;a1 = 
;d0 = delimiter
;d1 = 
_strtok:
    link    a5,#0

;check to see if there is a new input string.
    tst.l   (8,a5)
    beq .noNewInput
    move.l  (8,a5),strtokPtr
.noNewInput:

;inputs
    move.l strtokPtr,a0
    move.l  (12,a5),d0

.loop:
    tst.b   (a0)
    beq .endStr
    cmp.b   (a0)+,d0
    bne .loop
    
;found delim
    move.b  #0,(-1,a0)
    move.l  strtokPtr,d0
    move.l  a0,strtokPtr
    bra .exit
 
.endStr:
    moveq   #0,d0
.exit:
    unlk    a5
    rts

;---------------------------------------
;_strchr
;Searches for the first occurrence of the
;character c (an unsigned char) in the
;string pointed to, by the argument str.
;
;   pea c
;   pea str
;   bsr _strchr
;   addq.w  #8,sp
;---------------------------------------
_strchr:
    link    a5,#0
    
    move.l  (8,a5),a0
    move.l  (12,a5),d0
    
.loop:
    tst.b   (a0)
    beq .endOfString
    cmp.b   (a0)+,d0
    bne .loop
    subq    #1,a0
    move.l  a0,d0
    bra .exit
.endOfString:
    moveq   #0,d0
.exit:
    unlk    a5
    rts
    
;---------------------------------------
;_strrchr
;;Searches for the lst occurrence of the
;character c (an unsigned char) in the
;string pointed to, by the argument str.
;
;   pea c
;   pea str
;   bsr _strrchr
;   addq.w  #8,sp
;---------------------------------------
_strrchr:
    link    a5,#0
    
    move.l  (8,a5),a0
    move.l  (12,a5),d0
    move.l  #0,a1
    
.loop:
    tst.b   (a0)    ;end of string?
    beq .exit   ;yes: exit
    cmp.b   (a0)+,d0 ;no: target char?
    bne .loop  ;no: loop
    move.l  a0,a1    ;yes: save previous address
    subq    #1,a1
    bra .loop
.exit:
    move.l  a1,d0
    unlk    a5
    rts

;---------------------------------------
;---------------------------------------
Strings:
    dc.b    'Hello, this is a test string.',0
    dc.b    0

* Put variables and constants here
    org $00ff0000
    
strtokPtr    ds.l    1

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
