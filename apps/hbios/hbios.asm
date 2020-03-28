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

	PRTS(	"HBIOS Test Utility v0.3\r\n$")

	CALL	parse			; parse command line

	LD	iy, bcValue
	LD	B, 'B'
	LD	C, 'C'
	CALL 	prtregs

	LD	iy, deValue
	LD	B, 'D'
	LD	C, 'E'
	CALL	prtregs

	LD	iy, hlValue
	LD	B, 'H'
	LD	C, 'L'
	CALL	prtregs

	CALL	invokehbios

	PRTS(	"Returned registers\r\n$")
	PRTS(	"Ret DE: 0x$")
	LD	IY, deResult
	CALL	prtreg

	PRTS(	"\r\nRet HL: 0x$")
	LD	IY, hlResult
	CALL	prtreg

exit:
	CALL	crlf			; formatting
	LD	sp, (stksav)		; restore stack
	RET				; return to CP/M

prtregs:                               ; iy is location of data to print
	LD	a, b
	call	prtchr
	PRTS(	": 0x$")
	LD	a, (iy+1)                 ; b is chr of 1st register
	call	prthex
	CALL	crlf
	LD	a, c
	call	prtchr
	PRTS(	": 0x$")
	LD	a, (iy)                 ; b is chr of 1st register
	call	prthex
	call	crlf
	RET

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
	LD	de, (deValue)
	LD	hl, (hlValue)
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
	RET
;===============================================================================

readhexbyte:				; Read 2 chars - and convert to a byte - returned in A
	LD	a, (hl)
	OR	a
	JP	z, errprm
	CALL	fromchar
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
	LD	a, b
	INC	hl

	OR	c
	LD	c, a
	RET

;===============================================================================
; Parse command line
; if parse error, writes error string and then jp to exit

parse:
	LD	hl, $81			; point to start of command tail (after length byte)

	LD	IY, bcValue
	CALL	parsehexbyte

	LD	a, (hl)			; if no more args
	OR	a
	RET	z

	LD	IY, deValue		; D and E values
	CALL	parsehexbyte

	LD	a, (hl)			; if no more args
	OR	a
	RET	z

	LD	IY, hlValue		; H and L values
	CALL	parsehexbyte

	RET

parsehexbyte:
	CALL	nonblank		; skip blanks

	CALL	readhexbyte		; read value for register B
	LD	a, c
	LD	(IY + 1), a

	CALL	nonblank		; skip blanks

	CALL	readhexbyte		; read value for register C
	LD	a, c
	LD	(IY), a
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
	LD	a, (hl)			; load next character
	OR	a
	JP	z, erruse
	cp	' '			; string ends with a null
	JR	nz, errprm		; if no blank found as expected, return error to user

skipblank:
	INC	hl			; if blank, increment character pointer
	LD	a, (hl)			; load next character
	OR	a			; string ends with a null
	RET	z			; if null, return pointing to null
	CP	' '			; check for blank
	RET	nz			; return if not blank
	JR	skipblank		; and loop

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
	JP	exit


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

msguse		.db	"Usage: HBIOS BB CC [DD EE] [HH LL]$"
msgprm		.db	"Parameter error$"


;===============================================================================
; Register values to supply to hbios
bcValue		.dw	0
deValue		.dw	0
hlValue		.dw	0

;===============================================================================
; Captured register returned by hbios call

deResult	.dw	0
hlResult	.dw	0

	.end