;===============================================================================
; UTIL TO INVOKE A HBIOS FUNCTION
; USAGE B C ....
;

STKSIZ		.EQU	$200		; WORKING STACK SIZE
RESTART		.EQU	$0000		; CP/M RESTART VECTOR
BDOS		.EQU	$0005		; BDOS INVOCATION VECTOR
TMSCTRL1:	.EQU	1		; CONTROL BITS
TMSINTEN:	.EQU	5		; INTERRUPT ENABLE
TMSREGBIT:	.EQU	$80		; BIT TO INDICATE REGISTER WRITE

TMS_INT_NONE	.EQU	0
TMS_INT_NMI	.EQU	1
TMS_INT_IRQ	.EQU	2
TMS_DATREG	.EQU	$BE		; READ/WRITE DATA
TMS_CMDREG	.EQU	$BF		; READ STATUS / WRITE REG SEL

#DEFINE PRTS(S) CALL PRTSTRD \ .TEXT S
#DEFINE TMS_IODELAY NOP \ NOP

;===============================================================================
; ENTRY
;===============================================================================
	.ORG	$100
					; SETUP STACK
	LD	(STKSAV), SP		; SAVE STACK
	LD	SP, STACK		; SET NEW STACK

	PRTS(	"TMS INT TEST UTILITY V0.3$")

	CALL	INT

	PRTS(	"INSTALLED HANDLER\r\n$")

LOOP:
	LD	C, 1
	CALL	BDOS

	CP	' '
	JR	Z, EXIT

	CP	'I'
	JR	NZ, SKIP

	LD	A, (TMS_INIT9918_REG_1)
	SET 	TMSINTEN, A		; SET INTERRUPT ENABLE BIT
	LD	(TMS_INIT9918_REG_1), A
	LD 	C, TMSCTRL1
	CALL	TMS_SET

	PRTS(	"ACTIVATED CHIP\r\n$")

SKIP:
	CALL	CRLF
	LD	HL, COUNTER
	LD	A, (HL)
	CALL	PRTHEX
	INC	HL
	LD	A, (HL)
	CALL	PRTHEX
	INC	HL
	LD	A, (HL)
	CALL	PRTHEX
	INC	HL
	LD	A, (HL)
	CALL	PRTHEX
	CALL	CRLF
	JR	LOOP

EXIT:
	CALL	CRLF			; FORMATTING
	LD	SP, (STKSAV)		; RESTORE STACK
	RET				; RETURN TO CP/M

INT:
	DI
	LD	B, $FC			; SET INT VEC
	LD	C, $20
	LD	E, 0
	LD	HL, TESTINT
	RST	08
	LD	(PREVINT), HL
	EI
	RET

TMS_SET:
	OUT	(TMS_CMDREG),A		; WRITE IT
	TMS_IODELAY
	LD	A,C			; GET THE DESIRED REGISTER
	OR	$80			; SET BIT 7
	OUT	(TMS_CMDREG),A		; SELECT THE DESIRED REGISTER
	TMS_IODELAY
	RET


	.ORG	$8100

TESTINT:
 	IN 	A, (TMS_CMDREG)
	AND	$80
	JP	NZ, INT_COUNTER
	LD	HL, (PREVINT)
	JP	(HL)

INT_COUNTER:
	LD	HL, COUNTER		; POINT TO TICK COUNTER
	CALL	INC32HL
	OR	$FF
 	RET				; AND RETURN

INC32HL:
	INC	(HL)
	RET	NZ
	INC	HL
	INC	(HL)
	RET	NZ
	INC	HL
	INC	(HL)
	RET	NZ
	INC	HL
	INC	(HL)
	RET


PRTREGS:				; IY IS LOCATION OF DATA TO PRINT
	LD	A, B
	CALL	PRTCHR
	PRTS(	": 0X$")
	LD	A, (IY+1)		; B IS CHR OF 1ST REGISTER
	CALL	PRTHEX
	CALL	CRLF
	LD	A, C
	CALL	PRTCHR
	PRTS(	": 0X$")
	LD	A, (IY)			; B IS CHR OF 1ST REGISTER
	CALL	PRTHEX
	CALL	CRLF
	RET

;===============================================================================

PRTREG:					; PRINT 16 BIT VALUE AT IY
	LD	E, (IY)
	LD	D, (IY + 1)
	LD	A, D
	CALL	PRTHEX
	LD	A, E
	JP	PRTHEX


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
	AND	$0F	 		; LOW NIBBLE ONLY
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

;===============================================================================
; PRINT A STRING DIRECT: REFERENCED BY POINTER AT TOP OF STACK
; STRING MUST BE TERMINATED BY '$'
; USAGE:
; CALL PRTSTR
; .DB "HELLO$"

PRTSTRD:
	EX	(SP), HL
	CALL	PRTSTRZ
	EX	(SP), HL
	RET

;===============================================================================
; STORAGE SECTION
;===============================================================================

STKSAV		.DW	0		; STACK POINTER SAVED AT START
		.FILL	STKSIZ, 0	; STACK
STACK		.EQU	$		; STACK TOP


;===============================================================================
; MESSAGES

COUNTER:	.FILL	4, 0

PREVINT:
	.DW	0

TMS_INIT9918_REG_1:
	.DB	$50			; REG 1 - ENABLE SCREEN, SET MODE 1

	.END