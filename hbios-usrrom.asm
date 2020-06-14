;
; USRROM	TEMPLATE FOR A CUSTOM USER ROM
;
#INCLUDE	"std.asm"

CR	.EQU    0DH
LF	.EQU    0AH
;
	.ORG    USR_LOC

	ld	hl, RA_ENT
	call	PRTHEX_HL

	.echo "\r\n"
	.echo RA_BNK
	.echo "\r\n"
	.echo BID_USR
	.echo "\r\n"
	.echo RA_SRC
	.echo "\r\n"

	;LOAD FIRST 16 BYTES FROM EXTERNAL ROM?
	; ld	e,$30			;  FIRST PAGE IN EXTERNAL ROM
	; ld	d,BID_USR		; dest is user bank
	; ld	hl,256		; HL := image size
	; ld	b,BF_SYSSETCPY		; HBIOS func: setup bank copy
	; rst	08			; do it


	ld	e,RA_BNK			; source bank to E
	ld	d,BID_USR		; dest is user bank
	ld	hl,16		; HL := image size
	ld	b,BF_SYSSETCPY		; HBIOS func: setup bank copy
	rst	08


	; ld	de,STORE		; DE := run dest adr
	; ld	hl,0		; HL := image source adr
	; ld	b,BF_SYSBNKCPY		; HBIOS func: bank copy
	; rst	08			; do it


	ld	de,STORE		; DE := run dest adr
	ld	hl,RA_SRC		; HL := image source adr
	ld	b,BF_SYSBNKCPY		; HBIOS func: bank copy
	rst	08

	CALL	PRTSTRD
	.DB	"DRIVER DATA: ",0

	LD	B, 0
	LD	HL, STORE

LOOP:
	ld	a, (hl)
	call	COUT

	CALL	PRTSTRD
	.DB	" ", 0

	INC	HL
	DJNZ	LOOP

	CALL	CIN		; DO STUFF

	call	CRLF

	LD	B, 0
	LD	HL, STORE

LOOP2:
	LD	A, (HL)
	CALL	PRTHEX

	CALL	PRTSTRD
	.DB	" ", 0

	INC	HL
	DJNZ	LOOP2

	CALL	CIN		; DO STUFF

	; CHECK FOR EXT ROM
	; IF NOT THERE - LOAD CPM FROM INTERANAL ROM (romload)
	; ELSE LOAD EXT ROM????
;
;
;=======================================================================
; Load and run a ROM application, IX=ROM app table entry
;=======================================================================
;

RA_BNK	.EQU	BID_IMG0
RA_SIZE	.EQU	CPM_SIZ
RA_DEST	.EQU	CPM_LOC
RA_SRC	.EQU	$5000
RA_ENT	.EQU	CPM_ENT

romload:
	; Copy image to it's running location
	ld	e,RA_BNK			; source bank to E
	ld	d,BID_USR		; dest is user bank
	ld	hl,RA_SIZE		; HL := image size
	ld	b,BF_SYSSETCPY		; HBIOS func: setup bank copy
	rst	08			; do it

	ld	de,RA_DEST		; DE := run dest adr
	ld	hl,RA_SRC		; HL := image source adr
	ld	b,BF_SYSBNKCPY		; HBIOS func: bank copy
	rst	08			; do it



	jp	RA_ENT

;
pstr:
	ld	a,(hl)			; get next character
	or	a			; set flags
	inc	hl			; bump pointer regardless
	ret	z			; done if null
	call	COUT			; display character
	jr	pstr			; loop till done
;
;

;
; PRINT A STRING AT ADDRESS SPECIFIED IN HL
; STRING MUST BE TERMINATED BY '$'
; USAGE:
;   LD	HL,MYSTR
;   CALL PRTSTR
;   ...
;   MYSTR: .DB  "HELLO$"
;
PRTSTR:	LD	A,(HL)
	INC	HL
	CP	0
	RET	Z
	CALL	COUT
	JR	PRTSTR
;
; OUTPUT CHARACTER IN A TO CONSOLE DEVICE
;
COUT:	PUSH	AF
	PUSH	BC
	PUSH	DE
	LD	B,01H
	LD	C,0
	LD	E,A
	RST	08
	POP	DE
	POP	BC
	POP	AF
	RET
;
; OUTPUT CHARACTER IN A TO CONSOLE DEVICE
;
COUTE:	PUSH	AF
	LD	A,E
	CALL	COUT
	POP	AF
	RET
;
; WAIT FOR A CHARACTER FROM THE CONSOLE DEVICE AND RETURN IT IN A
;
CIN:	PUSH	BC
	LD	B,00H
	LD	C,00H
	RST	08
	LD	A,E
	POP	BC
	RET

;===============================================================================
; PRINT CHARACTER IN A WITHOUT DESTROYING ANY REGISTERS

;===============================================================================
; PRINT A STRING DIRECT: REFERENCED BY POINTER AT TOP OF STACK
; STRING MUST BE TERMINATED BY '$'
; USAGE:
;   CALL PRTSTR
;   .DB  "HELLO$"

PRTSTRD:
	EX	(SP), HL
	CALL	PRTSTRZ
	EX	(SP), HL
	RET


;===============================================================================
; PRINT A $ TERMINATED STRING AT (HL) WITHOUT DESTROYING ANY REGISTERS
PRTSTRZ:
	LD	A, (HL)			; GET NEXT CHAR
	INC	HL
	CP	0
	RET	Z
	CALL	COUT
	JR	PRTSTRZ

PRTHEX_DE:
	PUSH	HL
	EX	DE, HL
	CALL	PRTHEX_HL
	POP	HL
	RET

PRTHEX_HL:
	LD	A, H
	CALL	PRTHEX
	LD	A, L
	CALL	PRTHEX
	RET
;===============================================================================
; PRINT THE VALUE IN A IN HEX WITHOUT DESTROYING ANY REGISTERS

PRTHEX:
	PUSH	AF			; SAVE AF
	PUSH	DE			; SAVE DE
	CALL	HEXASCII		; CONVERT VALUE IN A TO HEX CHARS IN DE
	LD	A, D			; GET THE HIGH ORDER HEX CHAR
	CALL	COUT			; PRINT IT
	LD	A, E			; GET THE LOW ORDER HEX CHAR
	CALL	COUT			; PRINT IT
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
	CALL	COUT			; PRINT IT
	LD	A, 10			; <LF>
	JR	COUT			; PRINT IT

STORE:	.FILL	256, 0

SLACK	.EQU	(USR_END - $)
	.FILL	SLACK,00
	.ECHO	"User ROM space remaining: "
	.ECHO	SLACK
	.ECHO	" bytes.\n"
        .END

