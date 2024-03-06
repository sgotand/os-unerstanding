; vim: set ft=nasm nospell:

itoa:
  ; prepare stack flame
  ;  0x0 |
  ; ^^^^
  ; BP+0 | BP (last)
  ; BP+2 | IP (return) (pushed by caller)
  ; BP+4 | number
  ; BP+6 | &buf
  ; BP+8 | len(buf)
  ; BP+10| radix
  ; BP+12| flag (0bit: signed or not, 1bit: output sign or not, 2bit: fill 0)
  push  bp;
  mov   bp, sp;

  ; 
  ; caller save register before BIOS CALL
  ;  0x0|
  ; ^^^^
  ; ... | di
  ; ...
  ; BP-2| ax
  ; BP+0| BP (last)
  push  ax;
  push  bx;
  push  cx;
  push  dx;
  push  si;
  push  di;

  ; load args
  mov   ax, [bp+4];
  mov   si, [bp+6];
  mov   cx, [bp+8];

  mov   di, si;
  add   di, cx;
  dec   di;   dst=&dst[size - 1];

  mov   bx, word [bp+12]; load flags

  ; check signed or not from flag

  test bx, 0b0001
.10Q: je    .10E; なぜinline?
      cmp   ax, 0;
.12Q  jge   .12E; ax >= 0
      or    bx, 0b0010; flag |= OUTPUT_SIGN (always output - for negative value)
.12E:;
.10E:;

  ; check output sign or not from flag

  test bx, 0b0010
.20Q: je  .20E
      cmp ax, 0;;
.22Q: jge .22F; if < ax; then
      neg ax;   ax *= -1
      mov [si], byte '-';
      jmp .22E;

.22F:; if ax >0
      mov [si], byte '+';
.22E:;
  dec cx; bufi--

.20E:;
  mov bx, [bp+10]; bx = radix

.30L:; fill bufs
  mov dx, 0
  div bx; dx = dx:ax % radix, ax = dx:ax / radix

  mov si, dx
  mov dl, byte [.ascii + si]; dl = char for the modulo

  mov [di], dl; *dst == dl
  dec di

  cmp ax, 0
  loopnz  .30L

.30E:; fill blanks
  cmp cx, 0

.40Q: je .40E
  mov al, ' '
  cmp [bp + 12], word 0b0100
.42Q: jne .42E
  mov al, '0'

.42E:
  std; DF = -1 (direction)
  rep stosb; while(--cx) *di-- = ' ';

.40E:
  ;restore registers
  pop di
  pop si
  pop dx
  pop cx
  pop bx
  pop ax

  ; collapse stack flame
  mov sp, bp
  pop bp
  ret

.ascii db "012345678ABCDEF"; char table










