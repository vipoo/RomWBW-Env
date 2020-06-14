
	SECTION CODE

	PUBLIC	_hbSysSetCopy, _hbSysBankCopy

include "std.inc"

;extern byte hbSysSetCopy(byte sourceBankId, byte destinationBankId, int countOfBytesToCopy);
_hbSysSetCopy:
	LD	HL, 2
	ADD	HL, SP
	LD	B, BF_SYSSETCPY
  	LD 	E, (HL)		; sourceBankId
	INC	HL
	LD	D, (HL)		; destinationBankId
	INC	HL
	LD	A, (HL)		; countOfBytesToCopy
	INC	HL
	LD	H, (HL)
	LD	l, A
	RST	08
	LD	L, A
	RET


;extern byte hbSysBankCopy(void* source, void* destination);
_hbSysBankCopy:
	LD	HL, 4
	ADD	HL, SP
	LD	B, BF_SYSBNKCPY
  	LD 	E, (HL)		; destination (low)
	INC	HL
	LD	D, (HL)		; destination (high)
	DEC	HL
	DEC	HL
	LD	A, (HL)		; source (high)
	DEC	HL
	LD	L, (HL)		; source (low)
	LD	H, A
	RST	08
	LD	L, A
	RET

	SECTION IGNORE
