#!/bin/bash

# define an abort function to call on error
abort_build()
{
    echo
    echo BUILD FAILED
    exit 1
}

# create obj and bin folders if non exiting, since
# the development tools will not create them themselves
mkdir -p bin
mkdir -p obj

echo
echo Assemble the ASM code
echo --------------------------
assemble   flappy.asm            -o obj/flappy.vbin   || abort_build

echo
echo Convert the PNG textures
echo --------------------------
png2vircon textures/00_title.png -o obj/00_title.vtex || abort_build

echo
echo Convert the WAV sounds
echo --------------------------
wav2vircon sounds/00_title.wav   -o obj/00_title.vsnd || abort_build

echo
echo Pack the ROM
echo --------------------------
packrom flappy.xml               -o bin/flappy.v32    || abort_build

echo
echo BUILD SUCCESSFUL
