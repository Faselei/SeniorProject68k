*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
    
START:                  ; first instruction of program

* Put program code here
    link    a5,#-12
    
    ;00 - 03: 32 bit position in rom (static)
    ;04 - 07: 32 bit position from start of file (dynamic)
    ;08 - 11: 32 bit size (size)

    pea File_LEVEL00BIN
    move.l  a5,-(sp)
    bsr _fopen
    addq.w  #8,sp


    unlk    a5
    SIMHALT             ; halt simulator    
    
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
; c style fopen, must be in 8.3 string
; format. "12345678.9AB".
;
;   
;   pea addressOfString
;   pea locationOfFileStruct
;   bsr _fopen
;   addq.b  #8,sp
;---------------------------------------
_fopen:
    link    a5,#-12
    
    movem.l  d2/a2-a4,-(sp)
    
    move.l  (8,a5),a4   ;location of file struct
    move.l  (12,a5),a2  ;pointer to string

;call _strtok and parse the string
    pea '.'
    move.l  a2,-(sp)
    bsr _strtok
    addq.w  #8,sp
    
;find the length of the token
    move.l   d0,-(sp)
    bsr _strlen
    addq.w  #4,sp
    move.l  d0,d2

;if the string length is greater then 8, then this is not a valid file name
    cmp.b #8,d2
    bls .stringOk
    move.b #1,(_errno)
    moveq   #0,d0
    bra .exit
.stringOk:

    move.l  a2,-(sp)
    move.l  a5,-(sp)
    bsr _strcpy
    addq.w  #8,sp

.exit:
    movem.l   (sp)+,d2/a2-a4
    unlk    a5
    rts

* Put variables and constants here

File_LEVEL00BIN:
    dc.b    'LEVEL00.BIN',0

pak0dat:
    dc.b    76,69,86,69,76,48,48,32,66,73,78,0,0,0,0,41,73,32,106,117,115,116,32,110,101,101,100,32,115,111,109,116,104,105,110,103,32,116,111,32,112,117,116,32,104,101,114,101,32,105,110,32,99,97,115,101,46,0,84,73,84,76,69,71,70,88,66,73,78,0,0,0,0,59
    dc.b    84,73,84,76,69,71,70,88,46,66,73,78,32,116,104,105,115,32,110,101,101,100,115,32,116,111,32,98,101,32,97,110,32,111,100,100,32,110,117,109,98,101,114,32,111,102,32,99,104,97,114,97,99,116,101,114,115,46,32,0,83,116,111,114,121,32,32,32,116
    dc.b    120,116,0,0,0,0,74,79,107,32,105,116,32,105,115,32,50,48,58,52,57,32,111,110,32,106,97,110,32,49,39,115,116,32,50,48,50,50,44,32,106,117,115,116,32,119,114,105,116,105,110,103,32,116,104,105,115,32,110,111,119,32,116,111,32,116,101,115,116,32
    dc.b    109,97,107,101,80,97,107,46,101,120,101,0,0
    
    org $00FF0000
strtokPtr   ds.l    1
_errno	ds.b	1
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
