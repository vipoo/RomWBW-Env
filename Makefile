
.PHONY: all
.PHONY: rc2014
.PHONY: romwbw-rcz80-dino
.PHONY: cpm

all: rc2014 romwbw-rcz80-dino cpm

cpm:
	@(cd cpm && make)

rc2014:
	@(cd RC2014 && make)

romwbw-rcz80-dino:
	@./romwbw-build-cmd "" RCZ80 dino
