
.PHONY: all
.PHONY: test-build
.PHONY: romwbw-rcz80-dino
.PHONY: romwbw-rcz80-test
.PHONY: tools
.PHONY: apps
.PHONY: rcz80-rom-dino
.PHONY: rcz80-rom-test
.PHONY: romwbw

all: apps Tools Tune.com rcz80-dino-romwbw

test-build: apps Tools Tune.com rcz80-test-romwbw

export SHELL:=/bin/bash
export SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit

.ONESHELL:

.PHONY: Tools
Tools:
	$(MAKE) --directory RomWBW/Tools/unix

# Build the standard romwbw images
.PHONY: romwbw
romwbw:
	$(MAKE) --directory RomWBW

# Patch and build a custom dino image for use with testing
.PHONY: rcz80-dino-romwbw
rcz80-dino-romwbw:
	./romwbw-build-prep dino
	function cleanup() {
		./romwbw-build-cleanup dino
	}
	trap cleanup EXIT
	$(MAKE) --directory RomWBW

# Patch and build a custom dino image for use with testing
.PHONY: rcz80-test-romwbw
rcz80-test-romwbw:
	./romwbw-build-prep test
	function cleanup() {
		./romwbw-build-cleanup test
	}
	trap cleanup EXIT
	$(MAKE) --directory RomWBW

chip8:
	@./romwbw-build-cmd rom RCZ80 dino ../chip8/bin/chip8.com

runchip8:
	@rc2014 -b -f -s -r ./RomWBW/Binary/RCZ80_dino.rom


rcz80-rom-dino: Tune.com		# use windows cmd line to build dino image
	@./romwbw-build-cmd rom RCZ80 dino

rcz80-rom-test: Tune.com		# use windows cmd line to build test image
	@./romwbw-build-cmd rom RCZ80 test

apps:
	$(MAKE) --directory apps

.PHONY: Tune.com
Tune.com:
	$(MAKE) --directory RomWBW/Source/Apps/Tune

romwbw-rcz80-dino: Tune.com
	@./romwbw-build-cmd "" RCZ80 dino

romwbw-rcz80-test: Tune.com
	@./romwbw-build-cmd "" RCZ80 test
