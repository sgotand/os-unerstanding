; vim: set ft=nasm nospell:
puts:
  ; prepare stack flame
  ;  0x0|
  ; ^^^^
  ; BP+0| BP (last)
  ; BP+2| IP (return) (pushed by caller)
  ; BP+4| address to the string (pushed by caller)
  push  bp;
  mov   bp, sp;

  ; 
  ; caller save register before BIOS CALL
  ;  0x0|
  ; ^^^^
  ; BP-6| si
  ; BP-4| bx
  ; BP-2| ax
  ; BP+0| BP (last)
  push  ax
  push  bx
  push  si

  mov   si, [bp+4]

  ; set BIOS CALL args
  mov   ah, 0x0E;   BIOS CALL arg to specify teletype output 1char
  mov   bx, 0x0000; BIOS CALL arg to specify page num & color = 0

  cld;  DF=0 to specify addres direction to increment
.10L:   ; why .10L???
  lodsb ; AL=*SI++;

  cmp   al, 0;
  je    .10E; if AL== \0 (end of string) then break
  int   0x10; else CALL BIOS video service
  jmp   .10L;

.10E:


  ; restore registers
  pop si
  pop bx
  pop ax


  ; collapse stack flame
  mov sp, bp
  pop bp
  ret
