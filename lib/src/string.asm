;===============================================================================
;string.asm
;===============================================================================
;
;-------------------------------------------------------------------------------

;///////////////////////////////////////////////////////////////////////////////
	section	"BSS",bss

;strtok static
strtokPtr	ds.l	1
;///////////////////////////////////////////////////////////////////////////////
	section	"DATA",data
;///////////////////////////////////////////////////////////////////////////////
	section	"CODE",code

;---------------------------------------
;memchr
;
;finds a character c in the first n bytes
;of memory pointed by str.
;
;Calling Convention
;	move.l	#n,-(sp)
;	move.l	#c,-(sp)
;	pea	_string
;	bsr	_memchr
;	add.w	#12,sp
;result D0 = null or pointer to location in string
;---------------------------------------
;d0 = c
;d1 = n
;a0 = pointer to string
;
	public	_memchr
_memchr:
	link	a5,#0

	move.l	(8,a5),a0	;string
	move.l	(12,a5),d0	;character c
	move.l	(16,a5),d1	;number n
	bra	.enter		;start loop

.loop:	cmp.b	(a0)+,d0	;does the data match the character we want?
	bne	.enter		;no: skip
	subq	#1,a0		;yes: return *str - 1
	move.l	a0,d0
	bra	.exit

.enter:	dbra	d1,.loop	;no: loop
	moveq	#0,d0		;yes: return 0
.exit:	unlk	a5
	rts

;---------------------------------------
;memcmp
;
;compares the first n bytes of the 2 strings
;
;Calling Convention
;	move.l	#n,-(sp)
;	pea	string2
;	pea	string1
;	bsr	_memcmp
;	add.w	#12,sp
;result D0:
;	 0 = strings are the same
;	+# = string1 > string2
;	-# = string1 < string2
;---------------------------------------
;d0 = result
;d1 = n
;a0 = string1
;a1 = string2
;
	public	_memcmp
_memcmp:
	link	a5,#0
	move.l	(16,a5),d1	;n
	move.l	(12,a5),a1	;string2
	move.l	(8,a5),a0	;string1
	moveq	#0,d0
	bra	.enter
.loop:	move.b	(a0)+,d0	;load next character
	sub.b	(a1)+,d0	;equal?
	bne	.exit		;no: exit
.enter:	dbra	d1,.loop	;yes: n--, n = -1? no: goto loop
.exit:	unlk	a5
	rts

;---------------------------------------
;memcpy
;
;Copy 1 area of memory to anouther
;
;Calling Convention
;	move.l	#n,-(sp)
;	pea	src
;	pea	dest
;	bsr	_memcpy
;	add.w	#12,sp
;
;result D0:
;This function returns a pointer to
;the destination, which is dest
;---------------------------------------
	public	_memcpy
_memcpy:
	link	a5,#0

	move.l	(8,a5),a1	;dest
	move.l	(12,a5),a0	;src
	move.l	(16,a5),d0	;size n
	bra	.enter
.loop:	move.b	(a0)+,(a1)+
.enter:	dbra	d0,.loop
	move.l	(8,a5),d0
	unlk	a5
	rts

;---------------------------------------
;memset
;
;Fill a region of memory with the given value
;
;	move.l	#count,-(sp)
;	move.l	#c,-(sp)
;	pea	str
;	bsr	_memset
;	add.w	#12,sp
;---------------------------------------
	public	_memset
_memset:
	link	a5,#0
	move.l	(8,a5),a0	;str
	move.l	(12,a5),d0	;c
	move.l	(16,a5),d1	;count
	bra	.enter
.loop:	move.b	d0,(a0)+
.enter:	dbra	d1,.loop
	move.l	(8,a5),d0
	unlk	a5
	rts

;---------------------------------------
;strlen
;
;Computes the length of the string str
;up to but not including the terminating null character.
;
;Calling Convention
;	pea	str
;	bsr	_strlen
;	addq	#4,sp
;---------------------------------------
	public	_strlen
_strlen:
	link	a5,#0
	move.l	(8,a5),a0
	moveq	#0,d0
	bra	.enter
.loop:	addq	#1,d0
.enter:	tst.b	(a0)+
	bne	.loop
	unlk	a5
	rts

;---------------------------------------
;strcat
;
;Appends the string pointed to, by src to
;the end of the string pointed to by dest.
;
;Calling Convention
;	pea	src
;	pea	dest
;	bsr	_strcat
;	addq	#8,sp
;
;RETURNS:
;This function returns a pointer to the resulting string dest.
;---------------------------------------
	public	_strcat
_strcat:
	link	a5,#0

	move.l	(8,a5),a0	;dest
	move.l	a0,d0
	move.l	(12,a5),a1	;src

;find the end of the string
.loopA:	tst.b	(a0)+
	bne	.loopA
	subq	#1,a0

.loopB:	move.b	(a1)+,(a0)+
	bne	.loopB
	unlk	a5
	rts

;---------------------------------------
;strncat
;
;Appends the string pointed to, by src
;to the end of the string pointed to,
;by dest up to n characters long.
;
;Calling Convention char *strncat(char *dest, const char *src, size_t n)
;
;	move.l	#n,-(sp)
;	pea	src
;	pea	dest
;	bsr	_strncat
;	add.w	#12,sp
;
;RETURNS:
;This function returns a pointer to the resulting string dest.
;---------------------------------------
	public	_strncat
_strncat:
	link	a5,#0

	move.l	(8,a5),a0	;dest
	move.l	a0,d0
	move.l	(12,a5),a1	;src
	move.l	(16,a5),d1	;n

;if n is 0, then we just return
	tst	d1
	beq	.exit

;find the end of the string
.loopA:	tst.b	(a0)+
	bne	.loopA
	subq	#1,a0

.loopB:	move.b	(a1)+,(a0)+
	beq	.exit
	subq	#1,d1
	bne	.loopB
	move.b	#0,(a0)+

.exit:	unlk	a5
	rts

;---------------------------------------
;strchr
;
;This returns a pointer to the first
;occurrence of the character c in the
;string str, or NULL if the character
;is not found.
;
;Calling Convention strchr(const char *str, int c);
;
;	move.l	#c,-(sp)
;	pea	str
;	bsr	_strchr
;	addq	#8,sp
;
;RETURNS:
;pointer to first occurrance or null if
;none found.
;---------------------------------------
	public	_strchr
_strchr:
	link	a5,#0

	move.l	(8,a5),a0
	move.l	(12,a5),d0
	bra	.enter
.loop:	cmp.b	(a0)+,d0
	beq	.exit
.enter:	tst.b	(a0)
	bne	.loop
	move.l	#0,a0
.exit:	move.l	a0,d0
	unlk	a5
	rts

;---------------------------------------
;strcmp
;
;Compares the string pointed to, by
;str1 to the string pointed to by str2.
;
;Calling Convention int strcmp(const char *str1, const char *str2);
;	pea	str2
;	pea	str1
;	bsr	_strcmp
;	addq.w	#8,sp
;
;RETUNRS:
;This function return values that are as follows −
;if Return value < 0 then it indicates str1 is less than str2.
;if Return value > 0 then it indicates str2 is less than str1.
;if Return value = 0 then it indicates str1 is equal to str2.
;---------------------------------------
	public	_strcmp
_strcmp:
	link	a5,#0

	move.l	(8,a5),a0	;str1
	move.l	(12,a5),a1	;str2
	moveq	#0,d0
	bra	.enter

.loop:	cmp.b	(a0)+,(a1)+
	beq	.enter
	bcs	.lower
	moveq	#1,d0
	bra	.exit
.lower:	moveq	#-1,d0
	bra	.exit
.enter:	tst.b	(a0)
	bne	.loop
.exit:	unlk	a5
	rts

;---------------------------------------
;strncmp
;
;Compares at most the first n bytes of
;str1 and str2.
;
;Calling Convention:
;	move.l	#n,-(sp)
;	pea	str2
;	pea	str1
;	bsr	_strncmp
;	add.w	#12,sp
;
;RETUNRS:
;This function return values that are as follows −
;if Return value < 0 then it indicates str1 is less than str2.
;if Return value > 0 then it indicates str2 is less than str1.
;if Return value = 0 then it indicates str1 is equal to str2.
;---------------------------------------
	public	_strncmp
_strncmp:
	link	a5,#0

	move.l	(8,a5),a0	;str1
	move.l	(12,a5),a1	;str2
	move.l	(16,a5),d1	;n
	moveq	#0,d0
	bra	.enter

.loop:	cmp.b	(a0)+,(a1)+
	beq	.enter
	bcs	.lower
	moveq	#1,d0
	bra	.exit
.lower:	moveq	#-1,d0
	bra	.exit
	tst.b	(a0)
	beq	.exit
.enter:	dbra	d1,.loop
.exit:	unlk	a5
	rts

;---------------------------------------
;strcpy
;
;Copies up to n characters from the
;string pointed to, by src to dest.
;
;Calling Convention
;char *strcpy(char *dest, const char *src)
;	pea	src
;	pea	dest
;	bsr	_strcpy
;	addq.w	#8,sp
;
;RETURN:
;This returns a pointer to the
;destination string dest.
;---------------------------------------
	public	_strcpy
_strcpy:
	link	a5,#0

	move.l	(8,a5),a1	;dest
	move.l	a1,d0
	move.l	(12,a5),a0	;src
.loop:	move.b	(a0)+,(a1)+
	bne	.loop
	unlk	a5
	rts

;---------------------------------------
;strncpy
;
;Copies up to n characters from the
;string pointed to, by src to dest.
;
;Calling Convention
;
;	move.l	#n,-(sp)
;	pea	src
;	pea	dest
;	bsr	_strncpy
;
;RETURNS:
;This function returns the final copy
;of the copied string.
;---------------------------------------
	public	_strncpy
_strncpy:
	link	a5,#0

	move.l	(8,a5),a1	;dest
	move.l	a1,d0
	move.l	(12,a5),a0	;src
	move.l	(16,a5),d1	;n
	bra	.enter

.loop:	move.b	(a0),(a1)+
	tst.b	(a0)
	beq	.enter
	addq	#1,a0
.enter:	dbra	d1,.loop
	move.l	(8,a5),d0
	unlk	a5
	rts

;---------------------------------------
;strrchr
;
;Searches for the last occurrence of the
;character c (an unsigned char) in the
;string pointed to by the argument str.
;
;Calling Convention:
;	move.l	#c,-(sp)
;	pea	str
;	bsr	_strrchr
;	addq.w	#8,sp
;
;RETURNS:
;This function returns a pointer to the
;last occurrence of character in str.
;If the value is not found, the function
;returns a null pointer.
;---------------------------------------
	public	_strrchr
_strrchr:
	link	a5,#0
	move.l	(8,a5),a0
	move.l	(12,a5),d1
	moveq	#0,d0
.loop:	tst.b	(a0)
	beq	.exit
	cmp.b	(a0)+,d1
	bne	.loop
	move.l	a0,d0
	subq	#1,d0
	bra	.loop
.exit:	unlk	a5
	rts

;---------------------------------------
;strtok
;
;Breaks string str into a series of
;tokens separated by delim.
;
;If yoy want a new string to parse,
;pass a new string, else pass NULL
;
;NOTE: this method is distructive.
;please have the string in ram when
;using this.
;
;Calling Convention:
;	pea	delim
;	pea	str -or- 0
;	bsr	_strtok
;	addq.w	#8,sp
;
;RETUNRS:
;This function returns a pointer to the
;first token found in the string. A null
;pointer is returned if there are no
;tokens left to retrieve.
;---------------------------------------
	public	_strtok
_strtok:
	link	a5,#0

	move.l	(8,a5),a0
	move.l	(12,a5),d1
	moveq	#0,d0

;check that we have a new string.
	cmp.l	#0,a0
	beq	.noNewString
	move.l	a0,strtokPtr
.noNewString:

;load from previous string
	move.l	strtokPtr,a0
.loop:	tst.b	(a0)
	beq	.exit
	cmp.b	(a0)+,d1
	bne	.loop
	subq.l	#1,a0
	move.b	#0,(a0)+
	move.l	strtokPtr,d0
.exit:	move.l	a0,strtokPtr
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
