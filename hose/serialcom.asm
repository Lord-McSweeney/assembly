bits 16
org 0x7E00

section .text
    init:
        mov ah, 0x0E
    	mov si, _msg
    	xor cx, cx
    print:
        lodsb
	    or al, al
	    jz loop
	    int 0x10
	    jmp print
	loop:
	    mov ah, 3
	    mov dx, 0
	    int 0x14
	    and ax, 256
	    cmp ax, 256
	    je ready
	    jmp loop
	ready:
	    mov ah, 2
	    xor dx, dx
	    int 0x14
	    mov ah, 1
	    xor dx, dx
	    cmp al, 0x0D
	    je enterpressed
	    int 0x14
	    jmp loop
	enterpressed:
	    mov ah, 1
	    mov al, 0x0D
	    int 0x14
	    mov ah, 1
	    mov al, 0x0A
	    int 0x14
	    jmp loop
	_msg:
	    db "Starting communications...", 0x0D, 0x0A, 0

times 446 - ($-$$) db 0
db 0x80
db 0x00
db 0x01
db 0x00
db 0x01
db 0x00
db 0x08
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x08
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x00
db 0x55
db 0xAA
