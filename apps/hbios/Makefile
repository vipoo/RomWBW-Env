
UZ80AS=uz80as -x
ASSEMBLER=$(UZ80AS)

%.com: %.asm
	$(ASSEMBLER) $< $@ ;

.PHONY: all

all: hbios.com

hbios.com: hbios.asm
