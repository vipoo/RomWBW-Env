
ASSFLAGS=-v -b
ASSEMBLER=z80asm $(ASSFLAGS)

%.com: %.asm
	@$(ASSEMBLER) -o$@ $<
	@rm -f hello.o

.PHONY: all

all: hello.com

.PHONY: clean
clean:
	@rm -f hello.com
	@rm -f hello.o

hello.com: hello.asm
