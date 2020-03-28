;===============================================================================
; Util to invoke a HBIOS function
; Usage B C ....
;
stksiz	.equ	$200		; Working stack size
;
restart	.equ	$0000		; CP/M restart vector
bdos	.equ	$0005		; BDOS invocation vector


#DEFINE	PRTS(S)	CALL PRTSTRD \ .TEXT S

;===============================================================================
; Code Section
;===============================================================================
;
	.org	$100
				; setup stack
	LD	(stksav), sp	; save stack
	LD	sp, stack	; set new stack

	PRTS(	"HBIOS Test Utility v0.1\r\n$")

	CALL	parse		; parse command line
	JR	nz, exit

	PRTS(	"B: 0x$")		; print out register values supplied on ccp
	LD	bc, (bcValue)
	LD	a, b
	CALL	prthex
	PRTS(	"\r\nC: 0x$")
	LD	a, c
	CALL	prthex
	CALL	crlf

	CALL	invokehbios

	PRTS(	"Returned registers\r\nDE: 0x$")
	LD	IY, deResult
	CALL	prtreg

	PRTS(	"\r\nHL: 0x$")
	LD	IY, hlResult
	CALL	prtreg

	CALL	crlf		; newline

;
exit:
	CALL	crlf		; formatting
	LD	sp,(stksav)	; restore stack
	RET			; return to CP/M

;	print 16 byte value at IY
prtreg:
	LD	E, (IY)
	LD	d, (IY+1)
	LD	a, d
	CALL	prthex
	LD	a, e
	jp	prthex

invokehbios:
	LD	bc, (bcValue)
	RST	08
	LD	(deResult), de
	LD	(hlResult), hl
	RET

;
;  convert char in A to a number from 0-15 based on it HEX string value
; return in A
fromchar:
	sub	'0'
	cp	10		; greater than 9
	JR	c, numchar
	sub	17 		;'A' - '0'
	cp	7		; greater than F
	jp	nc, errprm
	add	a, 10

numchar:
	LD	b, a
	xor	a
	RET


; Read 2 chars - and convert to a byte - returned in A
readhexbyte:
	LD	a, (hl)
	or	a
	jp	z, erruse
	CALL	fromchar
	RET	nz
	LD	a, b

	rlca
	rlca
	rlca
	rlca
	LD	c, a

	inc	hl

	LD	a, (hl)
	or	a
	jp	z, erruse

	CALL	fromchar
	RET	nz
	LD	a, b

	inc	hl
	or	c
	LD	c, a
	xor	a
				; first arg in A
	RET

; Parse command line
; If success, Z set and HL points to device name string (zero terminated)
; ... else NZ set.
;


parse:
;
	LD	hl,$81		; point to start of command tail (after length byte)
	CALL	nonblank	; skip blanks
	jp	z, erruse	; no parms
;
	; next 2 bytes sho	LD be the hex chars
	CALL	readhexbyte
	RET	NZ
	LD	a, c
	LD	(bcValue + 1), a

	CALL	nonblank	; skip blanks
	jp	z, erruse	; no parms

	CALL	readhexbyte
	LD	a, c
	LD	(bcValue), a

	xor	a
	RET
;
; Print character in A without destroying any registers
;
prtchr:
	push	bc		; save registers
	push	de
	push	hl
	LD	e, a		; character to print in E
	LD	c,$02		; BDOS function to output a character
	CALL	bdos		; do it
	pop	hl		; restore registers
	pop	de
	pop	bc
	RET
;
; Print a '$' terminated string at (DE) without destroying any registers
;
prtstr:
	push	af
	push	bc		; save registers
	push	de
	push	hl
	LD	c, $09		; BDOS function to output a '$' terminated string
	CALL	bdos		; do it
	pop	hl		; restore registers
	pop	de
	pop	bc
	pop	af
	RET

;
; Print a $ terminated string at (HL) without destroying any registers
;
prtstrz:
	LD	a, (hl)		; get next char
	inc	hl
	cp	'$'
	RET	z
	CALL	prtchr
	JR	prtstrz
;
; Print the value in A in hex without destroying any registers
;
prthex:
	push	af		; save AF
	push	de		; save DE
	CALL	hexascii	; convert value in A to hex chars in DE
	LD	a, d		; get the high order hex char
	CALL	prtchr		; print it
	LD	a, e		; get the low order hex char
	CALL	prtchr		; print it
	pop	de		; restore DE
	pop	af		; restore AF
	RET			; done
;
; Convert binary value in A to ascii hex characters in DE
;
hexascii:
	LD	d, a		; save A in D
	CALL	hexconv		; convert low nibble of A to hex
	LD	e, a		; save it in E
	LD	a, d		; get original value back
	rlca			; rotate high order nibble to low bits
	rlca
	rlca
	rlca
	CALL	hexconv		; convert nibble
	LD	d, a		; save it in D
	RET			; done
;
; Convert low nibble of A to ascii hex
;
hexconv:
	and	$0F	     	; low nibble only
	add	a,$90
	daa
	adc	a,$40
	daa
	RET
;
; Start a new line
;
crlf:
	LD	a, 13		; <CR>
	CALL	prtchr		; print it
	LD	a, 10		; <LF>
	JR	prtchr		; print it
;
; Get the next non-blank character from (HL).
;
nonblank:
	LD	a,(hl)		; load next character
	or	a		; string ends with a null
	RET	z		; if null, return pointing to null
	cp	' '		; check for blank
	RET	nz		; return if not blank
	inc	hl		; if blank, increment character pointer
	JR	nonblank	; and loop
;
; Check character at (DE) for delimiter.
;
delim:	or	a
	RET	z
	cp	' '		; blank
	RET	z
	JR	c, delim1	; handle control characters
	cp	'='		; equal
	RET	z
	cp	'_'		; underscore
	RET	z
	cp	'.'		; period
	RET	z
	cp	':'		; colon
	RET	z
	cp	$3b		; semicolon
	RET	z
	cp	'<'		; less than
	RET	z
	cp	'>'		; greater than
	RET
delim1:
	; treat control chars as delimiters
	xor	a		; set Z
	RET			; return
;
; Compare $ terminated strings at HL & DE
; If equal return with Z set, else NZ
;
strcmp:
;
	LD	a,(de)		; get current source char
	cp	(hl)		; compare to current dest char
	RET	nz		; compare failed, return with NZ
	or	a		; set flags
	RET	z		; end of string, match, return with Z set
	inc	de		; point to next char in source
	inc	hl		; point to next char in dest
	JR	strcmp		; loop till done
;
; Add the value in A to HL (HL := HL + A)
;
addhl:
	add	a, l		; A := A + L
	LD	l, a		; Put result back in L
	RET	nc		; if no carry, we are done
	inc	h		; if carry, increment H
	RET			; and return

;
; Errors
;
erruse:				; command usage error (syntax)
	LD	de, msguse
	JR	err

errprm:				; command parameter error (syntax)
	LD	de, msgprm

err:				; print error string and return error signal
	CALL	crlf		; print newline
	CALL	prtstr		; print error string
	OR	$FF		; signal error
	RET			; done

;
; PRINT A STRING DIRECT: REFERENCED BY POINTER AT TOP OF STACK
; STRING MUST BE TERMINATED BY '$'
; USAGE:
;   CALL PRTSTR
;   .DB  "HELLO$"
;   ...
;
PRTSTRD:
	EX	(SP), HL
	CALL	prtstrz
	EX	(SP), HL
	RET

;
;===============================================================================
; Storage Section
;===============================================================================
;
stksav	.dw	0		; stack pointer saved at start
	.fill	stksiz, 0	; stack
stack	.equ	$		; stack top
;
; Messages
;
msguse	.db	"Usage: HBIOS BB CC$"
msgprm	.db	"Parameter error$"

msgb	.db	"B 0x$"
msgc	.db	", C 0x$"
;

bcValue		.dw	0

deResult	.dw	0
hlResult	.dw	0


	.end