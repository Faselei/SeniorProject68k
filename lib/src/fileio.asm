;===============================================================================
;fileio.asm
;===============================================================================
;FileAccess
;-------------------------------------------------------------------------------
	include "errno.inc"
	include "fileio.inc"
;///////////////////////////////////////////////////////////////////////////////
	section	"BSS",bss

;we store some calculations for our own reference later
fileTableStart ds.l 1
totalFiles ds.l	1

;///////////////////////////////////////////////////////////////////////////////
	section	"DATA",data
;///////////////////////////////////////////////////////////////////////////////
	section	"CODE",code

;---------------------------------------
;_flipEndian
;
;Description
;
;Calling Convention
;	move.l	d0,-(sp)
;	bsr	flipEndian
;	addq.w	#8,sp
;d0 = ouput
;---------------------------------------
	public	_flipEndian
_flipEndian:
	link	a5,#0
	move.l	(8,a5),d0
	rol.w	#8,d0
	swap	d0
	rol.w	#8,d0
	unlk	a5
	rts
;---------------------------------------
;_FileSystemInit
;
;Needs to call this once to start
;
;Calling Convention
;
;---------------------------------------
	public	_InitFileSystem
_InitFileSystem:
	link	a5,#0

;file table start address
	move.l	#_pak0,a0
	move.l	(PAK_FILETABLE,a0),d0	;start of the file table
	move.l	d0,-(sp)
	bsr	_flipEndian
	add.l	a0,d0
	move.l	d0,fileTableStart

;total number of files
	move.l	(PAK_FILETABLESIZE,a0),d0	;total file table size
	move.l	d0,-(sp)
	bsr	_flipEndian
	addq.w	#4,sp
	lsr.l	#6,d0		;number of files = total size / 64
	move.l	d0,totalFiles

	unlk	a5
	rts

;---------------------------------------
;_fopen
;
;malloc a file struct and populate the
;struct.
;
;Calling Convention:
;	move.l	_string,-(sp)
;	bsr	_fopen
;	addq.w	#4,sp
;
;	FILE* fopen(char* filename);
;---------------------------------------
;d2 = number of files to look through
;d3 = file struct
;a2 = input string
;a3 = current file in pak

	public	_fopen
_fopen:	link	a5,#0
	movem.l	d2-d3/a2-a3,-(sp)

;input string
	move.l	(8,a5),a2

;start of the file table
	move.l	fileTableStart,a3

;number of files in pak file
	move.l	totalFiles,d2
	bra	.enter

;do strcmp to see if the string in the file table is what we want
.loop	move.l	a2,-(sp)
	move.l	a3,-(sp)
	bsr	_strcmp
	addq.w	#8,sp
	tst.l	d0
	beq	.found
	add.l	#64,a3		;move onto next file by adding 64
.enter:	dbra	d2,.loop

;fine not found
	move.l	#FILE_NOT_FOUND,_errno
	moveq	#0,d0
	bra	.exit

;found the file
.found:	pea	8	;number of bytes needed for file struct
	bsr	_malloc	;and attempt to allocate that memory
	addq.w	#4,sp
	tst.l	d0	;did that fail?
	beq	.exit	;well now we have a problem now do we
	move.l	d0,a0	;need to do this for hacks
	move.l	(56,a3),d0	;offset from _pak0 to file
	move.l	d0,-(sp)
	bsr	_flipEndian
	addq.w	#4,sp
	move.l	d0,(FILE_DATA,a0)
	add.l	#_pak0,(FILE_DATA,a0)	;set to physical address
	move.l	(60,a3),d0	;size
	move.l	d0,-(sp)
	bsr	_flipEndian
	addq.w	#4,sp
	move.l	d0,(FILE_SIZE,a0)	;store size in correct endian
	move.l	a0,d0
.exit:	movem.l	(sp)+,d2-d3/a2-a3
	unlk	a5
	rts

;---------------------------------------
;_fclose
;
;closes a file and deletes the file pointer
;
;Calling Convention
;void	_fclose(FILE* file);
;
;	move.l	file,-(sp)
;	bsr	_fclose
;---------------------------------------
	public	_fclose
_fclose:
	link	a5,#0
	move.l	(8,a5),d0
	move.l	d0,-(sp)
	bsr	_free
	addq.w	#4,sp
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
