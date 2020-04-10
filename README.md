# RomWBW-Env

> [![Build Status](https://travis-ci.org/vipoo/RomWBW-Env.svg?branch=master)](https://travis-ci.org/vipoo/RomWBW-Env)

Container for developing and testing changes within RomWBW

## Prerequisites

See the travis.yml file for script to setup the dependencies

### Submodules

You need to pull the git submodules:

`git submodule update --recursive`

### cpm

Requires a specific fork of cpm for testing the code.

The fork can be found at: (cpm fork)[https://github.com/vipoo/cpm]

You can download the precompiled binaries - or build them yourself:

### rc2014

Requires a specific fork of rc2014 for testing the code.

The fork can be found at: (RC2014 fork)[https://github.com/vipoo/RC2014]

You can download the precompiled binaries - or build them yourself:

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

