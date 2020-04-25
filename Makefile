
.PHONY: all
.PHONY: romwbw-rcz80-dino
.PHONY: tools
.PHONY: apps
.PHONY: apps/hbios
.PHONY: rcz80-rom-dino
.PHONY: romwbw

all: romwbw

export SHELL:=/bin/bash
export SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit

.ONESHELL:

.PHONY: romwbw
romwbw: apps/hbios Tune.com
	./romwbw-build-prep
	function cleanup() {
		./romwbw-build-cleanup
	}
	trap cleanup EXIT
	$(MAKE) --directory RomWBW

rcz80-rom-dino: Tune.com
	@./romwbw-build-cmd rom RCZ80 dino

apps/hbios:
	$(MAKE) --directory apps/hbios

apps:
	$(MAKE) --directory apps

.PHONY: Tune.com
Tune.com:
	$(MAKE) --directory RomWBW/Source/Apps/Tune

romwbw-rcz80-dino: Tune.com
	@./romwbw-build-cmd "" RCZ80 dino
