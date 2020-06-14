
	EXTERN	_main           ;main() is always external to crt0 code

	SECTION code_crt_init
	ORG	$4100
	LD	sp, $6000
	; LD	BC, FULLSIZE
	; LD	HL, PHYSTART + FULLSIZE - 1
	; LD	DE, $4100 + FULLSIZE - 1
	; lddr

	SECTION	code_crt_main
	CALL	_main
	JP	0

PHYSTART:
	SECTION CODE
APPSTART:
	; ORG	$4100
	SECTION code_compiler
	SECTION code_l_sdcc
	SECTION code_math
	SECTION code_error
	SECTION code_l
	SECTION rodata_compiler
	SECTION data_clib
	SECTION data_stdio
	SECTION data_compiler

	SECTION BSS
	SECTION bss_compiler
	SECTION bss_error

	SECTION IGNORE
APPEND:
FULLSIZE	EQU	$ - APPSTART


PUBLIC STDIO_MSG_PUTC
PUBLIC STDIO_MSG_WRIT
PUBLIC STDIO_MSG_GETC
PUBLIC STDIO_MSG_EATC
PUBLIC STDIO_MSG_READ
PUBLIC STDIO_MSG_SEEK
PUBLIC STDIO_MSG_ICTL
PUBLIC STDIO_MSG_FLSH
PUBLIC STDIO_MSG_CLOS

defc STDIO_MSG_PUTC = 1
defc STDIO_MSG_WRIT = 2
defc STDIO_MSG_GETC = 3
defc STDIO_MSG_EATC = 4
defc STDIO_MSG_READ = 5
defc STDIO_MSG_SEEK = 6
defc STDIO_MSG_ICTL = 7
defc STDIO_MSG_FLSH = 8
defc STDIO_MSG_CLOS = 9


         SECTION data_clib
         SECTION data_stdio

         PUBLIC __stdio_open_file_list
         __stdio_open_file_list:  defw 0

	SECTION IGNORE
