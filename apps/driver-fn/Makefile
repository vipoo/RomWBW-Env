
ASSFLAGS=-v -b
ASSEMBLER=z80asm $(ASSFLAGS)

%.com: %.asm
	@$(ASSEMBLER) -l -o$@ $<
	@rm -f driverfn.o

.PHONY: all

all: driverfn.com

.PHONY: clean
clean:
	@rm -f driverfn.com
	@rm -f driverfn.o

driverfn.com: driverfn.asm
