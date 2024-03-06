
; vim: set ft=nasm nospell:

%include "../include/define.s"
%include "../include/macro.s"
; bios load MBR (512Byte 2^9) into 0x7c00~0x7DFF
; this is to load next(2nd) sector

ORG BOOT_LOAD; specify load adddress

entry:
  ; BPB
  jmp ipl
  times  90 - ($ - $$) db 0x90; 

ipl:
  cli; disable interrupt

  mov ax, 0x0000;
  mov ds, ax;
  mov es, ax;
  mov ss, ax;
  mov sp, BOOT_LOAD; SP = 0x7C00

  sti; enable interrupt

  mov [BOOT + drive.no], dl; save boot drive num passed from BIOS to dl

  ; print "2nd stage..."
  cdecl puts, .s0;

  mov bx, BOOT_SECT - 1;
  mov cx, BOOT_LOAD + SECT_SIZE;

  cdecl read_chs, BOOT, bx, cx;

  cmp ax, bx; (ax is remaining sector?)
  ; reboot if failed
.10Q: jz   .10E            ;if not succeeded then
.10T: cdecl puts, .e0;
      call  reboot;
.10E:
  jmp stage_2;

.s0   db "Booting...", 0x0A, 0x0D, 0; 0X0A == LF, 0x0D == CR, 0==$; this is section local
.e0   db "Error:sector read", 0;

ALIGN 2, db 0;
BOOT:         ; info for BOOT drive???
istruc  drive
  at  drive.no,   dw  0
  at  drive.cyln, dw  0
  at  drive.head, dw  0
  at  drive.sect, dw  2
iend

%include  "../modules/real/puts.s";
; %include  "../modules/real/itoa.s";
%include  "../modules/real/reboot.s";
%include  "../modules/real/read_chs.s";

  times 512 - 2 - ($ - $$) db 0;
  db 0x55, 0xAA;

; ---------
; |0x00000|
; ~~~~~~~~~
; |stack    |
; |-0x7c000-|
; |ipl      |
; |-0x7e000-|
; |2nd stage|


stage_2:
  ; put str
  cdecl puts, .s0;
  jmp $

.s0   db "2nd stage...", 0x0A, 0x0D, 0; 0X0A == LF, 0x0D == CR, 0==$


  times BOOT_SIZE - ($ - $$) db 0x00;

