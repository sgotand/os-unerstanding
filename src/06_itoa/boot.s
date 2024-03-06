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
  cdecl puts, .s0

  ; show nums
  cdecl itoa, 8086, .s1,  8,  10, 0b0001; "    8086" 

  cdecl puts, .s0
  jmp $ ;

.s0   db "Booting...", 0x0A, 0x0D, 0; 0X0A == LF, 0x0D == CR, 0==$
.s1   db "0000000000", 0x0A, 0x0D, 0; 0X0A == LF, 0x0D == CR, 0==$

ALIGN 2, db 0;
BOOT:         ; info for BOOT drive???
.DRIVE: dw 0  ; boot driver number???

%include  "../modules/real/puts.s"
%include  "../modules/real/itoa.s"

  times 512 - 2 - ($ - $$) db 0x00;
  db 0x55, 0xAA;

; ---------
; |0x00000|
; ~~~~~~~~~
; |stack  |
; |0x7c000|
; |program|

