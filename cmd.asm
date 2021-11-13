bits 16
org 0x7E00

section .text
    .init:
        mov si, _msg1
        call printstring
    .loop:
        mov si, _msg2
        call printstring
        call .kbdstuff
        jmp .loop
    .exit:
        cli
        hlt
    .kbdstuff:
        mov ah, 1
        int 0x16
        jz .kbdstuff
        xor ah, ah
        int 0x16
        cmp al, 0x0D
        je .execcommand1
        mov ah, 0x0E
        int 0x10
        xor bh, bh
        mov di, _bufferkbd
        mov bl, [_kbdbufferlen]
        add di, bx
        inc byte [_kbdbufferlen]
        xor cx, cx
        mov es, cx
        mov [es:di], al
        jmp .kbdstuff
    .execcommand1: ; lookup a command and execute the relative code.
        ;press enter
        mov ah, 0x0E
        mov al, 0x0D
        int 0x10
        mov al, 0x0A
        int 0x10
        ; flush the keyboard buffer
        call .execcommand2
        call .kbdbufferflush
        jmp .loop
    .execcommand2:
        mov bx, _bufferkbd
        mov si, _cmddata1
    .execcommand2mid:
        push si
        mov dx, 4
        call strcmp
        pop si
        add si, 16
        cmp si, 64
        je .execcommand2end
        cmp al, 0
        je .execcommand2mid
        sub si, 11
        call si
    .execcommand2end:
        ret
    .kbdbufferflush:
        mov bx, _bufferkbd
        xor ax, ax
        mov [_kbdbufferlen], byte 0
    .kbdbufferflushmid:
        mov [es:bx], byte 0
        inc ax
        inc bx
        cmp ax, 64 ; the max length of the keyboard buffer
        je .kbdbufferflushend
        jmp .kbdbufferflushmid
    .kbdbufferflushend:
        ret
    printstring: ; Prints a string. pointer should be in SI.
        mov ah, 0x0E
    printstringmid:
        lodsb
	    or al, al
	    jz printstringend
	    int 0x10
	    jmp printstringmid
	printstringend:
	    ret
	strcmp:
	    xor ax, ax
	    mov es, ax
    strcmp1: ; compares pnt BX, SI. DX is the string length. 
        mov cl, [es:bx]
        mov ch, [es:si]
        cmp dx, 0
        je strcmp2
        cmp cl, ch
        jne strcmp3
        inc bx
        inc si
        dec dx
        jmp strcmp1
    strcmp2:
        mov ax, 1
        ret
    strcmp3:
        xor ax, ax
        ret
    _kbdbufferlen:
        db 0
    _bufferkbd:
        db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    _buffer2:
        
    _msg1:
        db "Hose starting.", 0x0D, 0x0A, 0
    _msg2:
        db "cmd> "
        
times 368 - ($-$$) db 0
    _cmddata1:
        db 'e'
        db 'x'
        db 'i'
        db 't'
        db 0
        db 0xFA
        db 0xF4
        db 0xC3
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
    _cmddata2:
        db 'w'
        db 'a'
        db 'i'
        db 't'
        db 0
        db 0xF4
        db 0xF4
        db 0xF4
        db 0xF4
        db 0xF4
        db 0xF4
        db 0xF4
        db 0xF4
        db 0xF4
        db 0xF4
        db 0xC3
    _cmddata3:
        db 'h'
        db 'a'
        db 'n'
        db 'g'
        db 0xEB
        db 0xFE
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
    _cmddata4:
        db 'r'
        db 'e'
        db 's'
        db '1'
        db 0
        db 0xC3
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
    _cmddata5:
        db 'r'
        db 'e'
        db 's'
        db '2'
        db 0
        db 0xC3
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        db 0
        
times 510 - ($-$$) db 0
db 0x55
db 0xAA
