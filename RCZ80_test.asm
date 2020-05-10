;
;==================================================================================================
;   RC2014 Z80 STANDARD CONFIGURATION
;==================================================================================================
;
; THE COMPLETE SET OF DEFAULT CONFIGURATION SETTINGS FOR THIS PLATFORM ARE FOUND IN THE
; CFG_<PLT>.ASM INCLUDED FILE WHICH IS FOUND IN THE PARENT DIRECTORY.  THIS FILE CONTAINS
; COMMON CONFIGURATION SETTINGS THAT OVERRIDE THE DEFAULTS.  IT IS INTENDED THAT YOU MAKE
; YOUR CUSTOMIZATIONS IN THIS FILE AND JUST INHERIT ALL OTHER SETTINGS FROM THE DEFAULTS.
; EVEN BETTER, YOU CAN MAKE A COPY OF THIS FILE WITH A NAME LIKE <PLT>_XXX.ASM AND SPECIFY
; YOUR FILE IN THE BUILD PROCESS.
;
; THE SETTINGS BELOW ARE THE SETTINGS THAT ARE MOST COMMONLY MODIFIED FOR THIS PLATFORM.
; MANY OF THEM ARE EQUAL TO THE SETTINGS IN THE INCLUDED FILE, SO THEY DON'T REALLY DO
; ANYTHING AS IS.  THEY ARE LISTED HERE TO MAKE IT EASY FOR YOU TO ADJUST THE MOST COMMON
; SETTINGS.
;
; N.B., SINCE THE SETTINGS BELOW ARE REDEFINING VALUES ALREADY SET IN THE INCLUDED FILE,
; TASM INSISTS THAT YOU USE THE .SET OPERATOR AND NOT THE .EQU OPERATOR BELOW. ATTEMPTING
; TO REDEFINE A VALUE WITH .EQU BELOW WILL CAUSE TASM ERRORS!
;
; PLEASE REFER TO THE CUSTOM BUILD INSTRUCTIONS (README.TXT) IN THE SOURCE DIRECTORY (TWO
; DIRECTORIES ABOVE THIS ONE).
;
#include "cfg_rcz80.asm"
;
CPUOSC		.SET	7372800		; CPU OSC FREQ IN MHZ

ACIAENABLE	.SET	FALSE		; ACIA: ENABLE MOTOROLA 6850 ACIA DRIVER (ACIA.ASM)

SIOENABLE	.SET	TRUE		; SIO: ENABLE ZILOG SIO SERIAL DRIVER (SIO.ASM)

FDENABLE	.SET	TRUE		; FD: ENABLE FLOPPY DISK DRIVER (FD.ASM)
FDMODE		.SET	FDMODE_RCWDC	; FD: DRIVER MODE: FDMODE_[DIO|ZETA|DIDE|N8|DIO3]
FDMEDIA		.SET	FDM120		; FD: DEFAULT MEDIA FORMAT FDM[720|144|360|120|111]

IDEENABLE	.SET	FALSE		; IDE: DISABLE IDE DISK DRIVER (IDE.ASM)
PPIDEENABLE	.SET	FALSE		; PPIDE: DISABLE PARALLEL PORT IDE DISK DRIVER (PPIDE.ASM)
FDENABLE	.SET	FALSE		; FD: DISABLE FLOPPY DISK DRIVER (FD.ASM)

TMSENABLE       .SET    FALSE            ; TMS: ENABLE TMS9918 VIDEO/KBD DRIVER (TMS.ASM)

CRTACT		.SET	FALSE		; ACTIVATE CRT (VDU,CVDU,PROPIO,ETC) AT STARTUP
VDAEMU		.SET    EMUTYP_TTY	; VDA EMULATION: EMUTYP_[TTY|ANSI]
ANSITRACE	.SET    2		; ANSI DRIVER TRACE LEVEL (0=NO,1=ERRORS,2=ALL)
WBWDEBUG        .SET    USEXIO

SN76489ENABLE	.SET	TRUE		; SN76489 SOUND DRIVER
AUDIOTRACE	.SET	FALSE
;SN7CLK		.EQU	CPUOSC / 4	; DEFAULT TO CPUOSC / 4

TICKFREQ	.SET	60		; DESIRED PERIODIC TIMER INTERRUPT FREQUENCY (HZ)

#define BOOT_DEFAULT	"Z"
BOOT_TIMEOUT	.SET	0
#define MDRAMDISABLE

DSRTCENABLE	.SET	FALSE		; DSRTC: DISABLE DS-1302 CLOCK DRIVER (DSRTC.ASM)

AY38910ENABLE	.SET	TRUE
AY38910_FORCE	.EQU	TRUE		; DISABLE H/W DETECTION FOR TESTING
;AY_CLK		.EQU	CPUOSC / 4	; DEFAULT TO CPUOSC / 4