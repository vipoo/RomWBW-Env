
.PHONY: all
.PHONY: rc2014
.PHONY: romwbw-rcz80-dino
.PHONY: cpm
.PHONY: tools
.PHONY: apps
.PHONY: apps/hbios
.PHONY: uz80as
.PHONY: rcz80-rom-dino

all: apps/hbios romwbw-rcz80-dino

rcz80-rom-dino:
	@./romwbw-build-cmd rom RCZ80 dino

tools: cpm rc2014 uz80as

apps/hbios:
	$(MAKE) --directory apps/hbios

apps: apps/hbios

cpm:
	$(MAKE) --directory cpm

rc2014:
	$(MAKE) --directory RC2014 -j 8

uz80as:
	$(MAKE) --directory uz80as

romwbw-rcz80-dino:
	@./romwbw-build-cmd "" RCZ80 dino
