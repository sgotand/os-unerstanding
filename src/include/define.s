; vim: set ft=nasm nospell:
BOOT_LOAD equ 0x7c00; define load point (intel specific)
BOOT_END  equ (BOOT_LOAD + BOOT_SIZE)

BOOT_SIZE equ (1024 * 8);
SECT_SIZE equ (512);
BOOT_SECT equ (BOOT_SIZE / SECT_SIZE);

E820_RECORD_SIZE  equ  20

KERNEL_SIZE equ (1024 * 8)
KERNEL_LOAD equ 0x0010_1000
KERNEL_SECT equ (KERNEL_SIZE / SECT_SIZE)
