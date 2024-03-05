
; vim: set ft=asm :
; as this program is loaded from disk to memory
; this program is to specify both disk & memory
entry:
  jmp ipl; jump to ipl (initial program loader)
  ; 90 byte for BPB (boot parameter block)
  ; 0x90 is NOP
  ; $ is location point
  ; $$ is start point of this section
  ; so this means see p259
  ; db is a pseudo-instruction for define byte
  ; So This line is to fill NOP up to 90 byte from section start point
  times 90 - ($ - $$) db 0x90;
ipl:
  jmp $; # while(1);
  times 512 - 2 - ($ - $$) db 0x00; 
  db 0x55, 0xAA; these are magic to indicate MBR(Master Boot Record)
  
