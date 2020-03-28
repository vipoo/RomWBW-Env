
.PHONY: all
.PHONY: rc2014
.PHONY: romwbw-rcz80-dino
.PHONY: cpm
.PHONY: apps
.PHONY: apps/hbios

all: rc2014 romwbw-rcz80-dino cpm

apps/hbios:
	$(MAKE) --directory apps/hbios

apps: apps/hbios

cpm:
	@(cd cpm && make)

rc2014:
	@(cd RC2014 && make)

romwbw-rcz80-dino:
	@./romwbw-build-cmd "" RCZ80 dino
