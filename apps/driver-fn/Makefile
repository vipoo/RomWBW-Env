
UZ80AS=uz80as -x
ASSEMBLER=$(UZ80AS)

%.com: %.asm
	@$(ASSEMBLER) $< $@ ;

.PHONY: all

all: driverfn.com

.PHONY: clean
clean:
	@rm -f driverfn.com
	@rm -f driverfn.o

driverfn.com: driverfn.asm
