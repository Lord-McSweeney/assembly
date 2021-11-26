bits 16
org 0x7C00

section .text
    bootinit:
        mov ah, 0x0E
	    mov si, _bootmsg
    bootmsg:
        lodsb
        or al, al
        jz entersector1
        int 0x10
        jmp bootmsg
    entersector1:
        mov ah, 1
        int 0x16
        jz entersector1
        xor ah, ah
        int 0x16
        sub al, 0x30
        mov cl, al
        xor ch, ch
    bootinit2:
        mov ah, 0x0E
	    mov si, _msg2
    bootmsg2:
        lodsb
        or al, al
        jz entersector2
        int 0x10
        jmp bootmsg2
    entersector2:
        mov ah, 1
        int 0x16
        jz entersector2
        xor ah, ah
        int 0x16
        sub al, 0x30
        mov ah, 2
        push ax
    loadfromdisk:
        mov ax, 0x07E0
        mov es, ax
        xor dx, dx
        xor bx, bx
        pop ax
        int 0x13
        mov di, 0x7E00
        jmp di
    _bootmsg:
        db "Select sectors to boot from- enter the first sector to load. Enter a number. Do not press enter.", 0x0D, 0x0A, 0
    _msg2:
        db "Select sectors to boot from- enter how many sectors to load. Enter a number. Do not press enter.", 0x0D, 0x0A, 0

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
