#include <stdio.h>

#define byte char
#define ESC 27

#define FALSE 0
#define TRUE 1

#define ROMSIZE	    	512
#define RAMSIZE	    	512		//; SIZE OF RAM IN KB (MUST MATCH YOUR HARDWARE!!!)
#define BID_ROM0    	((byte)0x00)
#define BID_RAM0    	((byte)0x80)
#define BID_ROMN    	((byte)(BID_ROM0 + ((ROMSIZE / 32) - 1)))
#define BID_RAMN    	((byte)(BID_RAM0 + ((RAMSIZE / 32) - 1)))
#define BID_BOOT    	BID_ROM0	// BOOT BANK
#define BID_IMG0    	BID_ROM0 + 1	//; ROM LOADER AND FIRST IMAGES BANK
#define BID_IMG1    	BID_ROM0 + 2	//; SECOND IMAGES BANK
#define BID_FSFAT   	BID_ROM0 + 3	//; FAT FILESYSTEM DRIVER BANK
#define BID_ROMD0   	BID_ROM0 + 4	//; FIRST ROM DRIVE BANK
#define BID_ROMDN   	BID_ROMN	//; LAST ROM DRIVE BANK
#define BID_RAMD0   	BID_RAM0	//; FIRST RAM DRIVE BANK
#define BID_RAMDN   	((byte)(BID_RAMN - 4))	//; LAST RAM DRIVE BANK
#define BID_AUX	    	((byte)(BID_RAMN - 3))	//; AUX BANK (BPBIOS, ETC.)
#define BID_BIOS    	((byte)(BID_RAMN - 2))	//; BIOS BANK
#define BID_USR	    	((byte)(BID_RAMN - 1))	//; USER BANK (CP/M TPA, ETC.)
#define BID_COM	    	BID_RAMN	//; COMMON BANK, UPPER 32K
#define BID_ROMEX0    0x20		//$00000 to $07FFF
#define BID_ROMEX1    BID_ROMEX0 + 1	//;$08000 to $0FFFF
#define BID_ROMEX2    BID_ROMEX0 + 2	//;$10000 to $17FFF
#define BID_ROMEX3    BID_ROMEX0 + 3	//;$18000 to $1FFFF
#define BID_ROMEX4    BID_ROMEX0 + 4

extern byte hbCioOut(byte, char);
extern byte hbCioIn(byte, char*);

extern byte hbVdaInit(byte driver, byte mode, void* fontBitMap);
extern byte hbVdaWriteChar(byte, char);
extern byte hbVdaSetCursorPosition(byte, byte, byte);

extern byte hbSysSetCopy(byte sourceBankId, byte destinationBankId, int countOfBytesToCopy);
extern byte hbSysBankCopy(void* source, void* destination);

#define vdaInit(a, b, c)              abrtErr(hbVdaInit(a, b, c))
#define vdaSetCursorPosition(a, b, c) abrtErr(hbVdaSetCursorPosition(a, b, c))
#define vdaWriteChar(a, b)            abrtErr(hbVdaWriteChar(a, b))
#define vdaWriteString(a, b)          hbVdaWriteString(a, b)
#define cioIn(a, b)                   abrtErr(hbCioIn(a, b))

#define sysSetCopy(a, b, c)           abrtErr(hbSysSetCopy(a, b, c))
#define sysBankCopy(a, b)             abrtErr(hbSysBankCopy(a, b))

void hbVdaWriteString(const byte, const char*);
void hbCioOutString(const char* str) __z88dk_fastcall;
void outChr();
void abrtErr(byte result);
void startGame(byte firstBankId, byte secondBankId);
void startCpm();
void selectTms();
void fastClock();

typedef struct GameListStruct {
  byte  firstBankId;
  byte  secondBankId;
  const char* pName;
} GameList;

const GameList* gameList = (GameList*)0x5000;
int gameListCount;

int isRomInserted() {
  static byte store[5];

  hbSysSetCopy(BID_ROMEX0, BID_USR, 4);
  hbSysBankCopy(0, store);

  return store[0] == 0x31 &&
    store[1] == 0xB9 &&
    store[2] == 0x73 &&
    store[3] == 0xC3;
}

void abrtErr(byte result) {
  if (result != 0) {
    hbCioOutString("ERROR\r\n");
    __asm
    JP  0
    __endasm;
  }
}

byte testForArrows(byte p) __z88dk_fastcall {
  static char f;

  cioIn(0, &f);
  if (f != '[')
    return p;

  cioIn(0, &f);
  if (f == 'A')
    return p == 0 ? 0 : p-1;

  if (f == 'B')
    return p == gameListCount-1 ? gameListCount-1 : p+1;

  return p;
}

void loadGameList() {
  static GameList* pGameItem;

  hbSysSetCopy(BID_ROMEX0, BID_USR, 256);
  hbSysBankCopy((void*)0x2000, gameList);

  pGameItem = (GameList*)gameList;
  gameListCount = 0;
  while(pGameItem->firstBankId) {
    pGameItem->pName += 0x5000;
    pGameItem++;
    gameListCount++;
  }
}


void main() {
  fastClock();

  static int i;
  static int p = 0;
  static char f = 0;

  if (!isRomInserted()) {
    hbCioOutString("\r\nNo ROM Found\r\n");
    startCpm();
    return;
  }

  selectTms();
  hbCioOutString("\r\nFound ROM\r\n");

  loadGameList();

  vdaInit(0, 0, NULL);

  for(i = 0; i < gameListCount; i++) {
    vdaSetCursorPosition(0, i, 2);
    hbCioOutString(gameList[i].pName);
    vdaWriteString(0, gameList[i].pName);
  }

  vdaSetCursorPosition(0, p, 0);

  while(f != 'A') {
    cioIn(0, &f);
    if (f == ESC) {
      p = testForArrows(p);
      vdaSetCursorPosition(0, p, 0);
    }

    if (f == ' ') {
      hbCioOutString("Selected ");
      hbCioOutString(gameList[p].pName);
      hbCioOutString("\r\n");
      startGame(gameList[p].firstBankId, gameList[p].secondBankId);
      return;
    }
  }
}

void hbVdaWriteString(const byte driver, const char* str) {
  while(*str)
    vdaWriteChar(driver, *str++);
}

void hbCioOutString(const char* str) __z88dk_fastcall {
  while(*str)
    hbCioOut(0, *str++);
}
