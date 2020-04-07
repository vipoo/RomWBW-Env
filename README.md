# RomWBW-Env
Container for developing and testing changes within RomWBW

## Prerequisites

You need to pull the git submodules:

`git submodule update --recursive`

See the travis.yml file for reference for a clean setup

### uz80as

this assembler needs to installed into your system

```
cd uz80as
make
sudo make install
```

## Tools

* `romwbw-build-cmd <sub-command> <...args>`
This bash script will from WSL invoke the RomWBW build cmd windows cli scripts

example: `./romwbw-build-cmd shared` will run the BuildShared.cmd script


* `./run-rcz80-dino`

Invokes the RC2014 emulator for the binary rom image RomWBW/Binary/RCZ80_dino.rom

