; vim: set ft=nasm nospell:
BOOT_LOAD equ 0x7c00; define load point (intel specific)

BOOT_SIZE equ (1024 * 8);
SECT_SIZE equ (512);
BOOT_SECT equ (BOOT_SIZE / SECT_SIZE);

