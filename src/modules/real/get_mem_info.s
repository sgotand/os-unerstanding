; vim: set ft=nasm nospell tabstop=4:;
get_mem_info:;
	push	bp
	mov		bp, sp

	; save registers
	push	eax;
	push	ebx;
	push	ecx;
	push	edx;
	push	si;
	push	di;
	push	bp;


	mov		bp, 0		; lines = 0
	mov		ebx,0		; index = 0
.10L:;
	; E820 https://en.wikipedia.org/wiki/E820;
	mov		eax, 0x0000E820;

	mov		ecx, E820_RECORD_SIZE	;
	mov		edx, 'PAMS'				; 'SMAP'
	mov		di, .b0					; ES:DI = buffer; why ES?
	int		0x15;

	cmp	eax, 'PAMS'					; check supported or not
	je	.12E						; supported!
	jne	.10E						; error handling
.12E:;
	jnc	.14E						; check error (CF)
	jmp	.10E						; error handling
.14E:;
	
	; show 1 record
	cdecl	put_mem_info,	di		; show buffer contents

	; ACPI check & handle
	mov		eax, [di + 16]			; eax == type
	cmp		eax, 3					; test (type == ACPI_TYPE)
	jne 	.15E					; if not jump
	
	mov		eax, [di + 0]			; EAX = base address
	mov		[ACPI_DATA.adr], eax	; ACPI_DATA.adr = EAX
	mov		eax, [di + 8]			; EAX = length
	mov		[ACPI_DATA.len], eax	; ACPI_DATA.len = EAX

.15E:

	cmp	ebx, 0						; check index
	jz	.16E						; if then

	inc	bp							; if  0 < line < 8; then ok; else wait
	and	bp, 0x03					; if bp ==8 then bp =0					
	jnz	.16E						; if bp > 0 skip

	; show
	cdecl	puts, .s2				; show pending message
	mov	ah,	0x10					; wait key input

	int	0x16						;
	cdecl	puts, .s3				; elase pending message


.16E:;

	cmp ebx, 0						; 0 is set to ebx when the last record is read
	jne .10L;

.10E:								; while (ebx != 0); == while (!is_last)

	pop	bp;
	pop	di;
	pop	si;
	pop	edx;
	pop	ecx;
	pop	ebx;
	pop	eax;

	mov		sp, bp;
	pop		bp;
	ret;

.s2:	db "<more...>", 0
.s3:	db "0x0E", "        ", 0x0D, 0
.b0: 	times 1024 db 0x00;


put_mem_info:;
	;
	; prepare stack;
	push	bp;
	mov		bp,	sp;
;
	push	bx;
	push	si;
;
	mov		si, [bp+4]; buffer addr;
;
	; Base (64bit)
	cdecl	itoa, word [si + 6], .p2 + 0, 4, 16, 0b0100;
	cdecl	itoa, word [si + 4], .p2 + 4, 4, 16, 0b0100;
	cdecl	itoa, word [si + 2], .p3 + 0, 4, 16, 0b0100;
	cdecl	itoa, word [si + 0], .p3 + 4, 4, 16, 0b0100;

	; Length (64bit)
	cdecl	itoa, word [si + 6 + 8], .p4 + 0, 4, 16, 0b0100;
	cdecl	itoa, word [si + 4 + 8], .p4 + 4, 4, 16, 0b0100;
	cdecl	itoa, word [si + 2 + 8], .p5 + 0, 4, 16, 0b0100;
	cdecl	itoa, word [si + 0 + 8], .p5 + 4, 4, 16, 0b0100;

	; Type (64bit)
	cdecl	itoa, word [si + 18], .p6 + 0, 4, 16, 0b0100;
	cdecl	itoa, word [si + 16], .p6 + 4, 4, 16, 0b0100;

	cdecl puts, .s1


	mov	bx, [si + 16];
	and	bx, 0x07;
	shl	bx, 1;
	add	bx, .t0;
	cdecl puts, word [bx];

	pop si;
	pop bx;

	mov sp, bp;
	pop bp;
	ret;


.s1: db " ";
.p2: db "ZZZZZZZZ_";
.p3: db "ZZZZZZZZ ";
.p4: db "ZZZZZZZZ_";
.p5: db "ZZZZZZZZ ";
.p6: db "ZZZZZZZZ", 0;
;

.s4: db "(Unknown)", 0x0A, 0x0D, 0;
.s5: db	"(usable)", 0x0A, 0x0D, 0;
.s6: db "(reserved)", 0x0A, 0x0D, 0;
.s7: db "(ACPI data)", 0x0A, 0x0D, 0;
.s8: db "(ACPI NVS)", 0x0A, 0x0D, 0;
.s9: db "(bad memory)", 0x0A, 0x0D, 0;
;
.t0: dw .s4, .s5, .s6, .s7, .s8, .s9, .s4, .s4;
;
