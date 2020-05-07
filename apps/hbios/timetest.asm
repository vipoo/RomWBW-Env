;===============================================================================
; Util to test time vector installation/removal
; Usage B C ....
;

stksiz	.equ	$200		; Working stack size
restart	.equ	$0000		; CP/M restart vector
bdos	.equ	$0005		; BDOS invocation vector

#DEFINE	PRTS(S)	CALL prtstrd \ .TEXT S

BF_SYS			.EQU	$F0
BF_SYSSET		.EQU	BF_SYS + 9	; SET HBIOS PARAMETERS
BF_SYSINT		.EQU	BF_SYS + 12	; MANAGE INTERRUPT VECTORS
BF_SYSINT_ATMFN	.EQU	$30	; INSTALL NEW TIME TICK HANDLER
BF_SYSINT_RTMFN	.EQU	$40	; REMOVE TIME TICK HANDLER

BF_SYSSET_INC		.EQU	$D2	; SIMULATE TIMER TICK

;===============================================================================
; Entry
;===============================================================================
	.org	$100
					; setup stack
	LD	(stksav), sp		; save stack
	LD	sp, stack		; set new stack

	PRTS(	"Time test util\r\n$")

	JP	$8000
	.ORG	$8000

	PRTS("ADD TICK:\r\n$")
	LD	HL, TIMERTICK
	LD	DE, NEXTTIMETICK
	LD	B, BF_SYSINT
	LD	C, BF_SYSINT_ATMFN
	RST	08
	PUSH	AF
	PRTS("  A: 0x$")
	POP	AF
	CALL	prthex
	CALL	crlf

	PRTS("ADD TICK:\r\n$")
	LD	HL, TIMERTICK
	LD	DE, NEXTTIMETICK
	LD	B, BF_SYSINT
	LD	C, BF_SYSINT_ATMFN
	RST	08
	PUSH	AF
	PRTS("  A: 0x$")
	POP	AF
	CALL	prthex
	CALL	crlf

	PRTS("  a: COUNT=$")
	LD	A, (COUNTER)
	call	prthex
	CALL	crlf

	PRTS("INC:\r\n$")
	LD	B, BF_SYSSET
	LD	C, BF_SYSSET_INC
	RST	08

	PRTS("  b: COUNT=$")
	LD	A, (COUNTER)
	call	prthex
	CALL	crlf


	PRTS("REMOVE TICK:\r\n$")
	LD	HL, TIMERTICK
	LD	B, BF_SYSINT
	LD	C, BF_SYSINT_RTMFN
	RST	08
	PUSH	AF
	PRTS("  A: 0x$")
	POP	AF
	CALL	prthex
	CALL	crlf

	PRTS("INC:\r\n$")
	LD	B, BF_SYSSET
	LD	C, BF_SYSSET_INC
	RST	08

	PRTS("  c: COUNT=$")
	LD	A, (COUNTER)
	call	prthex
	CALL	crlf


	; VERIFY CANT REMOVE TWICE
	PRTS("REMOVE TICK:\r\n$")
	LD	HL, TIMERTICK
	LD	B, BF_SYSINT
	LD	C, BF_SYSINT_RTMFN
	RST	08
	PUSH	AF
	PRTS("  A: 0x$")
	POP	AF
	PUSH	AF
	CALL	prthex
	CALL	crlf
	POP	AF
	CP	$FF
	JR	NZ, fail1

	PRTS("INC:\r\n$")
	LD	B, BF_SYSSET
	LD	C, BF_SYSSET_INC
	RST	08

	PRTS("  d: COUNT=$")
	LD	A, (COUNTER)
	call	prthex
	CALL	crlf

exit:
	CALL	crlf
	LD	sp, (stksav)		; restore stack
	RET				; return to CP/M

fail1:
	PRTS("FAILED:$")
	JR	exit

TIMERTICK:
	LD	A, (COUNTER)
	INC	A
	LD	(COUNTER), A

TIMERTICK1:
	JP	0
	.DW	0
NEXTTIMETICK	.EQU	$ - 4

prtregs:				; iy is location of data to print
	LD	a, b
	call	prtchr
	PRTS(	": 0x$")
	LD	a, (iy+1)		; b is chr of 1st register
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
; Errors

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

COUNTER		.dw	0

stksav		.dw	0		; stack pointer saved at start
		.fill	stksiz, 0	; stack
stack		.equ	$		; stack top

	.end