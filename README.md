# RomWBW-Env

> MASTER: [![Build Status](https://travis-ci.org/vipoo/RomWBW-Env.svg?branch=master)](https://travis-ci.org/vipoo/RomWBW-Env)

> DEV: [![Build Status](https://travis-ci.org/vipoo/RomWBW-Env.svg?branch=dev)](https://travis-ci.org/vipoo/RomWBW-Env)

Container for developing and testing changes within RomWBW

## Prerequisites

See the travis.yml file for script to setup the dependencies

### Submodules

You need to pull the git submodules:

`git submodule update --recursive`

### cpm

Requires a specific fork of cpm for testing the code.

The fork can be found at: [cpm fork](https://github.com/vipoo/cpm)

You can download the precompiled binaries - or build them yourself:

### rc2014

Requires a specific fork of rc2014 for testing the code.

The fork can be found at: [RC2014 fork](https://github.com/vipoo/RC2014)

You can download the precompiled binaries - or build them yourself:

### uz80as

Requires a specific fork of uz80as for building the HBIOS test utility

The fork can be dound at [uz80as fork](https://github.com/vipoo/uz80as)

You can download the precompiled binaries - or build them yourself:

## Tools

* `romwbw-build-cmd <sub-command> <...args>`
This bash script will from WSL invoke the RomWBW build cmd windows cli scripts

example: `./romwbw-build-cmd shared` will run the BuildShared.cmd script


* `./run-rcz80-dino`

Invokes the RC2014 emulator for the binary rom image RomWBW/Binary/RCZ80_dino.rom

* `./run-rcz80-test`

Invokes the RC2014 emulator for the binary rom image RomWBW/Binary/RCZ80_test.rom

## Flashing onto a new ROM

`flash  --port COM3 write -f ./RomWBW/Binary/RCZ80_dino.rom --verify`
