bits 16
org 0x7E00

section .text
    init:
        xor ah, ah
        mov al, 3
        int 0x10
        mov ah, 0x0E
    	mov si, _msg1
    	xor cx, cx
    print1:
        lodsb
	    or al, al
	    jz loop
	    int 0x10
	    jmp print1
    loop:
        mov ah, 1
        int 0x16
        jz loop
        xor ah, ah
        int 0x16
        cmp ah, 0x48
        je cursorup
        cmp ah, 0x4B
        je cursorleft
        cmp ah, 0x4D
        je cursorright
        cmp ah, 0x50
        je cursordown
        cmp ah, 0x80
        je exit
        cmp ah, 0x78
        je coloredprintred
        cmp ah, 0x79
        je coloredprintyellow
        cmp ah, 0x7A
        je coloredprintgreen
        cmp ah, 0x7B
        je coloredprintblue
        cmp ah, 0x7C
        je coloredprintblack
        mov ah, 0x0E
        int 0x10
        cmp al, 0x0D
        je enter
        jmp loop
    coloredprintred:
        call begincoloredprint
        mov bl, 4
        int 0x10
        jmp loop
    coloredprintyellow:
        call begincoloredprint
        mov bl, 6
        int 0x10
        jmp loop
    coloredprintgreen:
        call begincoloredprint
        mov bl, 2
        int 0x10
        jmp loop
    coloredprintblue:
        call begincoloredprint
        mov bl, 1
        int 0x10
        jmp loop
    coloredprintblack:
        call begincoloredprint
        mov bl, 7
        int 0x10
        jmp loop
    begincoloredprint:
        mov ah, 8
        int 0x10
        mov ah, 9
        xor bh, bh
        mov cx, 1
        ret
    cursorup:
        call cursorstart
        sub dh, 1
        int 0x10
        jmp loop
    cursorleft:
        call cursorstart
        sub dl, 1
        int 0x10
        jmp loop
    cursordown:
        call cursorstart
        add dh, 1
        int 0x10
        jmp loop
    cursorright:
        call cursorstart
        add dl, 1
        int 0x10
        jmp loop
    cursorstart:
        mov ah, 3
        xor bh, bh
        int 0x10
        mov ah, 2
        xor bh, bh
        ret
    enter:
        mov ah, 0x0E
        mov al, 0x0A
        int 0x10
        jmp loop
    exit:
        mov si, _msg2
        xor al, al
        mov ah, 0x0E
    print2:
        lodsb
	    or al, al
	    jz done
	    int 0x10
	    jmp print2
    done:
        cli
        hlt
    _msg1:
        db "Start typing", 0x0D, 0x0A, 0
    _msg2:
        db "Exiting...", 0x0D, 0x0A, 0
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
