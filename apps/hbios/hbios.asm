;===============================================================================
; Util to invoke a HBIOS function
; Usage B C ....
;

stksiz	.equ	$200		; Working stack size
restart	.equ	$0000		; CP/M restart vector
bdos	.equ	$0005		; BDOS invocation vector

#DEFINE	PRTS(S)	CALL prtstrd \ .TEXT S

;===============================================================================
; Entry
;===============================================================================
	.org	$100
					; setup stack
	LD	(stksav), sp		; save stack
	LD	sp, stack		; set new stack

	PRTS(	"HBIOS Test Utility v0.1\r\n$")

	CALL	parse			; parse command line
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

exit:
	CALL	crlf			; formatting
	LD	sp, (stksav)		; restore stack
	RET				; return to CP/M

;===============================================================================

prtreg:					; print 16 bit value at IY
	LD	E, (IY)
	LD	d, (IY + 1)
	LD	a, d
	CALL	prthex
	LD	a, e
	JP	prthex

invokehbios:
	LD	bc, (bcValue)
	RST	08
	LD	(deResult), de
	LD	(hlResult), hl
	RET

;===============================================================================

					; convert char in A to a number from 0-15 based on it HEX string value
fromchar:				; value is returned in B
	SUB	'0'			;
	CP	10			; greater than 9
	JR	c, numchar
	SUB	'A' - '0'
	CP	7			; greater than F
	JP	nc, errprm
	ADD	a, 10

numchar:
	LD	b, a
	XOR	a			; return success
	RET
;===============================================================================

readhexbyte:				; Read 2 chars - and convert to a byte - returned in A
	LD	a, (hl)
	OR	a
	JP	z, errprm
	CALL	fromchar
	RET	nz
	LD	a, b
	RLCA
	RLCA
	RLCA
	RLCA
	LD	c, a
	INC	hl

	LD	a, (hl)
	OR	a
	JP	z, errprm
	CALL	fromchar
	RET	nz
	LD	a, b
	INC	hl

	OR	c
	LD	c, a
	XOR	a
	RET

;===============================================================================
; Parse command line
; If success, Z set and HL points to device name string (zero terminated)
; ... else NZ set.

parse:
	LD	hl,$81			; point to start of command tail (after length byte)
	CALL	nonblank		; skip blanks
	JP	z, erruse		; no parms

	CALL	readhexbyte		; read value for register B
	RET	NZ
	LD	a, c
	LD	(bcValue + 1), a

	CALL	nonblank		; skip blanks
	JP	z, erruse		; no parms

	CALL	readhexbyte		; read value for register C
	LD	a, c
	LD	(bcValue), a

	XOR	a			; return success
	RET

;===============================================================================
; Print character in A without destroying any registers

prtchr:
	PUSH	bc			; save registers
	PUSH	de
	PUSH	hl
	LD	e, a			; character to print in E
	LD	c, $02			; BDOS function to output a character
	CALL	bdos			; do it
	POP	hl			; restore registers
	POP	de
	POP	bc
	RET

;===============================================================================
; Print a $ terminated string at (HL) without destroying any registers
prtstrz:
	LD	a, (hl)			; get next char
	INC	hl
	CP	'$'
	RET	z
	CALL	prtchr
	JR	prtstrz

;===============================================================================
; Print the value in A in hex without destroying any registers

prthex:
	PUSH	af			; save AF
	PUSH	de			; save DE
	CALL	hexascii		; convert value in A to hex chars in DE
	LD	a, d			; get the high order hex char
	CALL	prtchr			; print it
	LD	a, e			; get the low order hex char
	CALL	prtchr			; print it
	POP	de			; restore DE
	POP	af			; restore AF
	RET				; done

;===============================================================================
; Convert binary value in A to ascii hex characters in DE

hexascii:
	LD	d, a			; save A in D
	CALL	hexconv			; convert low nibble of A to hex
	LD	e, a			; save it in E
	LD	a, d			; get original value back
	RLCA				; rotate high order nibble to low bits
	RLCA
	RLCA
	RLCA
	CALL	hexconv			; convert nibble
	LD	d, a			; save it in D
	RET				; done

;===============================================================================
; Convert low nibble of A to ascii hex

hexconv:
	AND	$0F	     		; low nibble only
	ADD	a, $90
	DAA
	ADC	a, $40
	DAA
	RET

;===============================================================================
; Start a new line

crlf:
	LD	a, 13			; <CR>
	CALL	prtchr			; print it
	LD	a, 10			; <LF>
	JR	prtchr			; print it

;===============================================================================
; Get the next non-blank character from (HL).

nonblank:
	LD	a,(hl)			; load next character
	OR	a			; string ends with a null
	RET	z			; if null, return pointing to null
	CP	' '			; check for blank
	RET	nz			; return if not blank
	INC	hl			; if blank, increment character pointer
	JR	nonblank		; and loop


;===============================================================================
; Errors

erruse:					; command usage error (syntax)
	LD	hl, msguse
	JR	err

errprm:					; command parameter error (syntax)
	LD	hl, msgprm

err:					; print error string and return error signal
	CALL	crlf			; print newline
	CALL	prtstrz			; print error string
	OR	$FF			; signal error
	RET				; done

;===============================================================================
; PRINT A STRING DIRECT: REFERENCED BY POINTER AT TOP OF STACK
; STRING MUST BE TERMINATED BY '$'
; USAGE:
;   CALL PRTSTR
;   .DB  "HELLO$"

prtstrd:
	EX	(SP), HL
	CALL	prtstrz
	EX	(SP), HL
	RET

;===============================================================================
; Storage Section
;===============================================================================

stksav		.dw	0		; stack pointer saved at start
		.fill	stksiz, 0	; stack
stack		.equ	$		; stack top


;===============================================================================
; Messages

msguse		.db	"Usage: HBIOS BB CC$"
msgprm		.db	"Parameter error$"


;===============================================================================
; Register values to supply to hbios
bcValue		.dw	0

;===============================================================================
; Captured register returned by hbios call

deResult	.dw	0
hlResult	.dw	0

	.end