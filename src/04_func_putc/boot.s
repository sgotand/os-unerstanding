; vim: set ft=nasm nospell:
BOOT_LOAD equ 0x7c00; define load point (intel specific)
ORG BOOT_LOAD; specify load adddress

%include "../include/macro.s"

ipl:
  cli; disable interrupt

  mov ax, 0x0000;
  mov ds, ax;
  mov es, ax;
  mov ss, ax;
  mov sp, BOOT_LOAD; SP = 0x7C00

  sti; enable interrupt
  mov [BOOT.DRIVE], dl; save boot drive num passed from BIOS to dl

  ; show chars
  cdecl putc, word 'X'
  cdecl putc, word 'Y'
  cdecl putc, word 'Z'

  jmp $ ;

ALIGN 2, db 0;
BOOT:;
.DRIVE: dw 0;

%include  "../modules/real/putc.s"

  times 512 - 2 - ($ - $$) db 0x00;
  db 0x55, 0xAA;

; ---------
; |0x00000|
; ~~~~~~~~~
; |stack  |
; |0x7c000|
; |program|

