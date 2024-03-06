; vim: set ft=nasm nospell:
reboot:
  cdecl puts, .s0;
.10L:
  ; set BIOS CALL args
  mov   ah, 0x10;   BIOS CALL arg
  int   0x16;       BIOS CALL to wait key input
  ; AL = BIOS(0x16, 0x10) read key input

  cmp   al, ' ';
  jne   .10L;

  ; output CR LF
  cdecl puts, .s1;

  int   0x19; reboot

.s0 db  0x0A, 0x0D, "Push SPACE key to reboot...", 0
.s1 db  0x0A, 0x0D,0x0A, 0x0D, 0
  

  
