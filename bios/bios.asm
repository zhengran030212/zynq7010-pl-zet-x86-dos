; Minimal 8086 BIOS for Zet SoC on Zynq-7010 - flat binary at 0xFE000
	cpu	8086
	org	0xFE000-0xFE000	; we ORG at file offset 0, segment FE00
	section .text

%define UART_DATA	0x60
%define UART_STAT	0x64
%define DISK_DLO	0x170
%define DISK_SEC	0x174
%define DISK_CMD	0x176

;======= code (loaded at phys 0xFE000, segment FE00:0000) =======
start:
	cli
	xor	ax, ax
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0x7C00
	sti

	; IVT entries at physical 0x0000
	mov	word [0x10*4],   int10
	mov	word [0x10*4+2], 0xFE00
	mov	word [0x13*4],   int13
	mov	word [0x13*4+2], 0xFE00
	mov	word [0x16*4],   int16
	mov	word [0x16*4+2], 0xFE00
	mov	word [0x19*4],   int19
	mov	word [0x19*4+2], 0xFE00

	mov	si, msg
.print:	lodsb
	test	al, al
	jz	.done
	out	UART_DATA, al
	jmp	.print
.done:
	int	0x19
	hlt

msg:	db "Zet8086 BIOS 0.1",13,10,0

int10:
	cmp	ah, 0x0E
	jne	.ret
	out	UART_DATA, al
.ret:	iret

int16:
	cmp	ah, 1
	je	.check
	in	al, UART_DATA
	iret
.check:	xor	ax, ax
	iret

int13:
	cmp	ah, 0x02
	je	.read
	cmp	ah, 0x00
	je	.reset
	xor	ah, ah
	iret
.reset:	xor	ah, ah
	clc
	iret
.read:
	push	cx
	; sector in CL
	mov	ax, cx
	out	DISK_SEC, ax
	mov	ax, 1
	out	DISK_CMD, ax
.wait:	in	ax, DISK_CMD
	test	ax, ax
	jnz	.wait
	; copy 256 words -> 512 bytes to ES:BX
	mov	cx, 256
.copy:	in	ax, DISK_DLO
	mov	[es:bx], ax
	inc	bx
	inc	bx
	loop	.copy
	pop	cx
	xor	ah, ah
	clc
	iret

int19:
	mov	ax, 0x0201
	xor	cx, cx
	inc	cx			; sector 1
	xor	dx, dx
	mov	bx, 0x7C00
	xor	ax, ax
	mov	es, ax
	int	0x13
	jc	.fail
	db	0xEA			; far jump imm
	dw	0x7C00
	dw	0x0000
.fail:
	mov	si, errmsg
.p:	lodsb
	test	al,al
	jz	.h
	out	UART_DATA, al
	jmp	.p
.h:	hlt

errmsg:	db "Boot failed",13,10,0

;======= pad + reset vector =======
	times	0xFF0-($-$$) db 0x90
resetvec:
	db	0xEA			; far jmp FE00:0000
	dw	0x0000
	dw	0xFE00
