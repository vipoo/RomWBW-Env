
UZ80AS=uz80as -x
ASSEMBLER=$(UZ80AS)

%.com: %.asm
	@$(ASSEMBLER) $< $@ ;

.PHONY: all

all: inttest.com

inttest.com: inttest.asm
