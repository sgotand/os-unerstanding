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
  jmp stage_2nd;

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
%include  "../modules/real/reboot.s";
%include  "../modules/real/read_chs.s";
  times 512 - 2 - ($ - $$) db 0;
  db 0x55, 0xAA;

FONT:; allocat FONT data to easily decidable place to access from both real & protect mode
.seg: dw 0 ; 2 byte for font data segment
.off: dw 0 ; 2 byte for font data ofset

ACPI_DATA:
.adr: dd 0 ; base addr 32bit
.len: dd 0 ; region length 32bit

; -----------
; |0x00000  |
; ~~~~~~~~~~~
; |stack    |
; |-0x7c000-|
; |ipl      |
; |-0x7e000-|
; |font addr|
; |2nd stage|


%include  "../modules/real/itoa.s";
%include  "../modules/real/get_drive_param.s";
%include  "../modules/real/get_font_adr.s";
%include  "../modules/real/get_mem_info.s";
%include  "../modules/real/kbc.s";
%include  "../modules/real/read_lba.s";
%include  "../modules/real/lba_chs.s";

stage_2nd:
  ; put str
  cdecl puts, .s0;

  ;get drive params

  cdecl get_drive_param, BOOT;
  cmp ax, 0
.10Q: jne   .10E            ;if not succeeded then
.10T: cdecl puts, .e0;
      call  reboot;
.10E:
  mov   ax, [BOOT + drive.no]   ; AX = ブートドライブ;
  cdecl itoa, ax, .p1, 2, 16, 0b0100 ; 
  mov   ax, [BOOT + drive.cyln]   ; 
  cdecl itoa, ax, .p2, 4, 16, 0b0100 ; 
  mov   ax, [BOOT + drive.head]   ; AX = ヘッド数;
  cdecl itoa, ax, .p3, 2, 16, 0b0100 ; 
  mov   ax, [BOOT + drive.sect]   ; AX = トラックあたりのセクタ数;
  cdecl itoa, ax, .p4, 2, 16, 0b0100 ; 
  cdecl puts, .s1

  jmp stage_3rd

.s0   db "2nd stage...", 0x0A, 0x0D, 0; 0X0A == LF, 0x0D == CR, 0==$
.s1   db " Drive:0x"
.p1   db "  , C:0x"
.p2   db "    , H:0x"
.p3   db "  , S:0x"
.p4   db "  ", 0x0A, 0x0D, 0
.e0   db "Error:can't get drive params", 0;


stage_3rd:

  cdecl puts, .s0;

  cdecl get_font_adr, FONT; FONT is a section

  cdecl itoa, word [FONT.seg], .p1, 4, 16, 0b0100
  cdecl itoa, word [FONT.off], .p2, 4, 16, 0b0100

  cdecl puts, .s1; since s1 has no EOS (\0), .p1 & p2 will be shown

  jmp stage_get_mem_info


.s0   db "3rd stage...", 0x0A, 0x0D, 0; 0X0A == LF, 0x0D == CR, 0==$
.s1   db " Font Address = "
.p1   db "ZZZZ:"
.p2   db "ZZZZ", 0x0A, 0x0D, 0


stage_get_mem_info:
  
  cdecl get_mem_info, ACPI_DATA; why? ACPI_DATA is missing in text
  ; check if ACPI_DATA fetch succeeded or not
  mov   eax, [ACPI_DATA.adr]
  cmp   eax, 0
  je  .09E; if err != nil jump to error handling

  cdecl itoa, ax, .p4,  4,  16, 0b0100; convert lower 16bit
  shr   eax, 16; shift right; eax>>= 16;
  cdecl itoa, ax, .p3,  4,  16, 0b0100; convert upper 16bit
  cdecl puts, .s2;

  jmp .10E

.09E:
  cdecl puts, .s3;

.10E:

  jmp stage_4;



.s2 db "ACPI data="
.p3 db "ZZZZ"
.p4 db "ZZZZ", 0x0A, 0x0D, 0

.s3 db "ACPI_DATA wasn't loaded", 0x0A, 0x0D, 0


stage_4:
  
  cdecl puts, .s0

  cli                       ; disable interrupt
  cdecl KBC_Cmd_Write,  0xAD; disable keyboard

  cdecl KBC_Cmd_Write,  0xD0; instruct to read out port
  cdecl KBC_Data_Read,  .key; read out port data
  mov   bl, [.key]
  or    bl, 0x02            ; set A20

  cdecl KBC_Cmd_Write,  0xD1; instruct to write out port
  cdecl KBC_Data_Write, bx  ; write out port data

  cdecl KBC_Cmd_Write,  0xAE; enable keyboard
  sti                       ; enable interrupt

  cdecl puts, .s1

  jmp stage_5

.s0   db "4th stage...", 0x0A, 0x0D, 0; 0X0A == LF, 0x0D == CR, 0==$
.s1   db " A20 Gate Enabled", 0x0A, 0x0D, 0; 0X0A == LF, 0x0D == CR, 0==$
.key: dw 0; buf

stage_5:

  cdecl puts, .s0
  cdecl read_lba, BOOT, BOOT_SECT, KERNEL_SECT, BOOT_END

  cmp ax, KERNEL_SECT

.10Q: jz  .10E
.10T: 

  cdecl puts, .e0
  call  reboot

.10E:
  jmp $

 
.s0   db "5th stage...", 0x0A, 0x0D, 0; 0X0A == LF, 0x0D == CR, 0==$
.e0   db " Failure load kernel...", 0x0A, 0x0D, 0; 0X0A == LF, 0x0D == CR, 0==$

  times BOOT_SIZE - ($ - $$) db 0x00;

