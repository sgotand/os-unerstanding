; vim: set ft=nasm nospell:
putc:
  ; prepare stack flame
  ;  0x0|
  ; ^^^^
  ; BP+0| BP (last)
  ; BP+2| IP (return) (pushed by caller)
  ; BP+4| output char (pushed by caller)
  push bp;
  mov bp, sp; set current bp. here bp==sp
  
  ; caller save register before BIOS CALL
  ;  0x0|
  ; ^^^^
  ; BP-4| bx
  ; BP-2| ax
  ; BP+0| BP (last)
  push ax
  push bx

  ; start main steps to call BIOS CALL
  mov al, [bp+4]; set output char to al
  mov ah, 0x0E;   BIOS CALL arg to specify teletype output 1char
  mov bx, 0x0000; BIOS CALL arg to specify page num & color = 0
  int 0x10;       VIDEO BIOS CALL

  ; restore registers
  pop bx
  pop ax


  ; collapse stack flame
  mov sp, bp
  pop bp
  ret

