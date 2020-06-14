.PHONY: all
all: extromldr.com

%.asm: %.c
	zcc +embedded -subtype=none -clib=sdcc_iy  -cleanup -m -S --max-allocs-per-node200000  --list $< -o $@  -create-app -Cs --Werror

extromldr.com: extromldr.asm crt.asm hbios_cio.asm hbios_vda.asm hbios_sys.asm loader.asm
	z80asm -v -o=$(basename $<).bin  -mz80 -b -L. -L"${ZCCCFG}/../../libsrc/_DEVELOPMENT/lib/sdcc_iy" -I"${ZCCCFG}/../../libsrc/_DEVELOPMENT/target/z80" -I"${ZCCCFG}/../../libsrc/_DEVELOPMENT/target/hbios" -I"/home/dean/retro/z88dk/lib/config/../../lib"  -D__SDCC -D__SDCC_IY -Iz80 crt.asm $(filter-out crt.asm,$^)
	@cat $(basename $<)_code_crt_init.bin > $(basename $<).img
	@truncate -s 4k  $(basename $<).img
	@rm -f *.o
	@rm -f $(basename $<)_code_crt_init.bin
	@rm -f $(basename $<)_CODE.bin
	@cp $(basename $<).img ../../RomWBW/Source/HBIOS

clean:
	rm -f *.o
	rm -f *.bin
	rm -f extromldr.asm
	rm -f extromldr.com
	rm -f e.com
	rm -f zcc_opt.def
	rm -f extromldr.err
	rm -f *.lis
	rm -f *.ihx
	rm -f *.map
	rm -f *.rom
	rm -f *.lst
	rm -f *.img
