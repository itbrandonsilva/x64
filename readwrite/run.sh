#!/bin/bash

nasm -f bin -o bootloader.bin bootloader.S
dd status=noxfer conv=notrunc if=bootloader.bin of=bootloader.flp
qemu-system-x86_64 -fda bootloader.flp
