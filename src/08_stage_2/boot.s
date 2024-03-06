; vim: set ft=nasm nospell:
BOOT_LOAD equ 0x7c00; define load point (intel specific)
ORG BOOT_LOAD; specify load adddress

%include "../include/macro.s"
; bios load MBR (512Byte 2^9) into 0x7c00~0x7DFF
; this is to load next(2nd) sector

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

  mov [BOOT.DRIVE], dl; save boot drive num passed from BIOS to dl

  ; print "2nd stage..."
  cdecl puts, .s0


  ;read next 512 byte
  mov   ah, 0x02          ; AH = read sector
  mov   al, 1             ; AL = sector count
  mov   cx, 0x0002        ; CX = cylinder/sector
  mov   dh, 0x00          ; DH = head
  mov   dl, [BOOT.DRIVE]  ; DL = drive number
  mov   bx, 0x7C00 + 512  ; BX = destination offset
  int   0x13              ; BIOS set CF=0 if scuuceeded
  ; reboot if failed
.10Q: jnc   .10E            ;if not succeeded then
.10T: cdecl puts, .e0;
      call  reboot;
.10E: ;
  jmp stage_2;



.s0   db "Booting...", 0x0A, 0x0D, 0; 0X0A == LF, 0x0D == CR, 0==$; this is section local
.e0   db "Error:sector read", 0;

ALIGN 2, db 0;
BOOT:         ; info for BOOT drive???
.DRIVE: dw 0  ; boot driver number???

%include  "../modules/real/puts.s"
; %include  "../modules/real/itoa.s"
%include  "../modules/real/reboot.s"

  times 512 - 2 - ($ - $$) db 0x00;
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


  times (1024 * 8) - ($ - $$) db 0x00;

