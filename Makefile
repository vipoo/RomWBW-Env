
.PHONY: all
.PHONY: romwbw-rcz80-dino
.PHONY: tools
.PHONY: apps
.PHONY: apps/hbios
.PHONY: rcz80-rom-dino
.PHONY: romwbw

all: apps/hbios romwbw

export SHELL:=/bin/bash
export SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit

.ONESHELL:

.PHONY: romwbw
romwbw:
	cp ./apps/hbios/hbios.com ./RomWBW/Source/RomDsk/ROM_512KB/hbios.com
	function cleanup {
		rm ./RomWBW/Source/RomDsk/ROM_512KB/hbios.com
	}
	trap cleanup EXIT
	$(MAKE) --directory RomWBW

rcz80-rom-dino:
	@./romwbw-build-cmd rom RCZ80 dino

apps/hbios:
	$(MAKE) --directory apps/hbios

apps:
	$(MAKE) --directory apps

romwbw-rcz80-dino:
	@./romwbw-build-cmd "" RCZ80 dino
