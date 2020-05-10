RESTART	EQU	$0000		; CP/M RESTART VECTOR
BDOS	EQU	$0005		; BDOS INVOCATION VECTOR

	ORG	100H

	LD	HL, (6)
	LD	SP, HL

	LD	HL, HELLO
	CALL	PRTSTRZ

	JP	RESTART

HELLO:
	DEFM	"HELLO WORLD\R\N$"
;===============================================================================
; PRINT CHARACTER IN A WITHOUT DESTROYING ANY REGISTERS

PRTCHR:
	PUSH	BC			; SAVE REGISTERS
	PUSH	DE
	PUSH	HL
	LD	E, A			; CHARACTER TO PRINT IN E
	LD	C, $02			; BDOS FUNCTION TO OUTPUT A CHARACTER
	CALL	BDOS			; DO IT
	POP	HL			; RESTORE REGISTERS
	POP	DE
	POP	BC
	RET

;===============================================================================
; PRINT A $ TERMINATED STRING AT (HL) WITHOUT DESTROYING ANY REGISTERS
PRTSTRZ:
	LD	A, (HL)			; GET NEXT CHAR
	INC	HL
	CP	'$'
	RET	Z
	CALL	PRTCHR
	JR	PRTSTRZ

;===============================================================================
; PRINT THE VALUE IN A IN HEX WITHOUT DESTROYING ANY REGISTERS

PRTHEX:
	PUSH	AF			; SAVE AF
	PUSH	DE			; SAVE DE
	CALL	HEXASCII		; CONVERT VALUE IN A TO HEX CHARS IN DE
	LD	A, D			; GET THE HIGH ORDER HEX CHAR
	CALL	PRTCHR			; PRINT IT
	LD	A, E			; GET THE LOW ORDER HEX CHAR
	CALL	PRTCHR			; PRINT IT
	POP	DE			; RESTORE DE
	POP	AF			; RESTORE AF
	RET				; DONE

;===============================================================================
; CONVERT BINARY VALUE IN A TO ASCII HEX CHARACTERS IN DE

HEXASCII:
	LD	D, A			; SAVE A IN D
	CALL	HEXCONV			; CONVERT LOW NIBBLE OF A TO HEX
	LD	E, A			; SAVE IT IN E
	LD	A, D			; GET ORIGINAL VALUE BACK
	RLCA				; ROTATE HIGH ORDER NIBBLE TO LOW BITS
	RLCA
	RLCA
	RLCA
	CALL	HEXCONV			; CONVERT NIBBLE
	LD	D, A			; SAVE IT IN D
	RET				; DONE

;===============================================================================
; CONVERT LOW NIBBLE OF A TO ASCII HEX

HEXCONV:
	AND	$0F	     		; LOW NIBBLE ONLY
	ADD	A, $90
	DAA
	ADC	A, $40
	DAA
	RET

;===============================================================================
; START A NEW LINE

CRLF:
	LD	A, 13			; <CR>
	CALL	PRTCHR			; PRINT IT
	LD	A, 10			; <LF>
	JR	PRTCHR			; PRINT IT
