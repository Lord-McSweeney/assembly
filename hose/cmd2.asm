; Bootloader
bits 16
org 0x7C00

section .text
    loadfromdisk:
        mov ax, 0x7E0
        mov es, ax
        xor dx, dx
        xor bx, bx
        mov ax, 0x0201 ; load one sector (bootsector is only one sector)
        mov cx, 2 ; bootsector is located at sector 2
        int 0x13
        
        xor ax, ax
        mov es, ax
        xor dx, dx
        mov bx, 0xA800
        mov ax, 0x0204 ; Read 4 filesystem sectors
        mov cx, 3 ; filesystem is located beginning from sector 3
        int 0x13
        mov di, 0x7E00
        jmp di

times 510 - ($-$$) db 0
db 0x55
db 0xAA


; Actual code
; 0x8400: keyboard buffer location (1 KB length)
; 0x8000: filesystem location
; 0x9000-0x9800: programs are loaded here- program memory (2 kb, 4 sectors)
; 0x8E00-0x8A00: stack location (1 kb, 2 sectors)
; 0x9800: guaranteed 0 bytes for at least 4 kB
; interrupt 0x60: print zero-terminated string. pointer in SI.
; interrupt 0x61: compare two strings, SI and BX pointers. Compare for DX bytes.
; interrupt 0x62: gives a pointer to the file named DI (4 byte pointer). CX is set to 1 if the file doesn't exist. If the file does exist, CX will be set to a pointer to the file.
    .init:
        mov ax, printstring
        xor bx, bx
        mov es, bx
        mov di, 0x180
        mov [es:di], al
        inc di
        mov [es:di], ah
        
        mov ax, strcmp
        mov di, 0x184
        mov [es:di], al
        inc di
        mov [es:di], ah
        
        mov ax, getfilepointer
        mov di, 0x188
        mov [es:di], al
        inc di
        mov [es:di], ah
        
        mov si, _msg1
        int 0x60
        mov bp, 0xE00
        mov sp, bp
        mov ax, 0x800
        mov ss, ax
    .loop:
        mov si, _msg2
        int 0x60
        call .kbdstuff
        jmp .loop
    .kbdstuff:
        mov ah, 1
        int 0x16
        jz .kbdstuff
        xor ah, ah
        int 0x16
        cmp ah, 0x0E
        je .backspace
        cmp al, 0x0D
        je .execcommand1
        mov ah, 0x0E
        int 0x10
        xor bh, bh
        mov di, 0x8400
        mov bl, [_kbdbufferlen]
        add di, bx
        inc byte [_kbdbufferlen]
        xor cx, cx
        mov es, cx
        mov [es:di], al
        jmp .kbdstuff
    .backspace:
        cmp [_kbdbufferlen], byte 0
        je .kbdstuff
        int 0x10
        mov ax, 0x0E00
        int 0x10
        mov al, 0x08
        int 0x10
        dec byte [_kbdbufferlen]
        jmp .kbdstuff
    .execcommand1: ; lookup a command and execute the relative code.
        ;press enter
        mov ah, 0x0E
        mov al, 0x0D
        int 0x10
        mov al, 0x0A
        int 0x10
        cmp byte [_kbdbufferlen], 0 ; if there's nothing in the keyboard buffer, just do nothing.
        je .execcommand1end
        ; flush the keyboard buffer
        call .execcommand2
        call .kbdbufferflush
    .execcommand1end:
        ret
    .execcommand2:
        mov di, 0x8400
        int 0x62
        cmp cx, 1
        je .commandnotfound
        add cx, 64 ; FSPAR file length
        mov si, cx
        mov cx, 0x9000
        push si
        push dx
        mov bx, cx
        mov si, 0x9800
        mov dx, 0x200 ; FSPAR filesystem length
        call memcpy
        pop dx
        pop si
        
        sub si, 55 ; FSPAR file body length
        mov bx, cx
        mov dx, 55 ; FSPAR file body length
        call memcpy
        
        xor ax, ax
        xor bx, bx
        xor cx, cx
        xor dx, dx
        xor si, si
        xor di, di
        call 0x9000
        ret
    .commandnotfound:
        mov si, _msg3
        int 0x60
        ret
    .kbdbufferflush:
        mov bx, 0x8400
        xor al, al
        mov [_kbdbufferlen], byte 0
    .kbdbufferflushmid:
        mov [es:bx], byte 0
        inc al
        inc bx
        cmp al, 128 ; the max length of the keyboard buffer
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
	    iret
	strcmp:
	    xor ax, ax
	    mov es, ax
    strcmp1: ; compares BX to SI for DX bytes. Returns 1 if they are equal, and 0 if not. CHANGES SI, DX, AND DI!
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
        inc ax ; ax is already set to 0 on line 134
        iret
    strcmp3:
        xor ax, ax
        iret
    memcpy:
	    xor ax, ax
	    mov es, ax
    memcpy1: ; copies SI to BX for DX bytes.
        mov cl, [es:si]
        mov [es:bx], cl
        cmp dx, 0
        je memcpy2
        inc bx
        inc si
        dec dx
        jmp memcpy1
    memcpy2:
        ret
    getfilepointer: ; gives a pointer to the file named DI. CX is set to 1 if the file doesn't exist. If the file does exist, CX will be set to a pointer to the file.
        mov si, 0xA800
        push si
        add si, 0x200 ; FSPAR filesystem length
        mov bx, si
        pop si
    getfilepointer1:
        push bx
        push si
        mov bx, di
        mov dx, 8 ; FSPAR file name length
        int 0x61
        pop si
        pop bx
        cmp ax, 1
        je getfilepointer3
        cmp bx, si
        je getfilepointer2
        add si, 64 ; FSPAR file length
        jmp getfilepointer1
    getfilepointer2:
        mov cx, 1
        iret
    getfilepointer3:
        mov cx, si
        iret
    _kbdbufferlen:
        db 0
    _msg1:
        db "Hose starting.", 0x0D, 0x0A, 0
    _msg2:
        db "cmd> ", 0
    _msg3:
        db "Command not found.", 0x0D, 0x0A, 0
    _fnameextension:
        db ".lbc"
times 1024 - ($-$$) db 0
    _cmddata1:
        db 'h'
        db 'a'
        db 'l'
        db 't'
        db '.'
        db 'l'
        db 'b'
        db 'c'
        db 0
    .exit:
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
        db 0
        db 0
        db 0
        db 0
    _cmddata2:
        db 'w'
        db 'a'
        db 'i'
        db 't'
        db '.'
        db 'l'
        db 'b'
        db 'c'
        db 0
        hp3_start:
            xor bx, bx
            mov es, bx
            mov si, 0x8409
            mov dx, [es:si]
            or dx, dx
            jz hp3_end
            sub dx, 0x30
        hp3_loop:
            hlt
            or dx, dx
            jz hp3_end
            dec dx
            jmp hp3_loop
        hp3_end:
            ret
        times 1152 - ($-$$) db 0
    _cmddata3:
        db 'c'
        db 'm'
        db 'd'
        db '?'
        db '.'
        db 'l'
        db 'b'
        db 'c'
        db 0
        db 0xBF
        db 0x09
        db 0x84
        db 0xCD
        db 0x62
        db 0x83
        db 0xF9
        db 0x01
        db 0x75
        db 0x08 ; FSPAR file name length
        db 0xB4
        db 0x0E
        db 0xEB
        db 0x02
        db 0xCD
        db 0x60
        db 0xB8
        db 0x0D
        db 0x0E
        db 0xCD
        db 0x10
        db 0xB0
        db 0x0A
        db 0xCD
        db 0x10
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
        db 'p'
        db 'r'
        db 'n'
        db 't'
        db '.'
        db 'l'
        db 'b'
        db 'c'
        db 0
        db 0xBE
        db 0x06
        db 0x90
        db 0xCD
        db 0x60
        db 0xC3
        db 'H'
        db 'e'
        db 'l'
        db 'l'
        db 'o'
        db ','
        db ' '
        db 'w'
        db 'o'
        db 'r'
        db 'l'
        db 'd'
        db '!'
        db 0x0D
        db 0x0A
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
        db 0
        db 0
        db 0
        db 0
    _cmddata5:
        db 'e'
        db 'c'
        db 'h'
        db 'o'
        db '.'
        db 'l'
        db 'b'
        db 'c'
        db 0
        db 0xBE
        db 0x09
        db 0x84
        db 0xCD
        db 0x60
        db 0xB8
        db 0x0D
        db 0x0E
        db 0xCD
        db 0x10
        db 0xB0
        db 0x0A
        db 0xCD
        db 0x10
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
    _cmddata6:
        db 'l'
        db 'i'
        db 's'
        db 't'
        db '.'
        db 'l'
        db 'b'
        db 'c'
        db 0
        hp1_start:
            mov si, 0xA800
            push si
            add si, 512 ; FSPAR filesystem length
            mov di, si
            pop si
        hp1_loop:
            push si
            int 0x60
            pop si
            add si, 64 ; FSPAR file length
            mov ax, 0x0E0D
            int 0x10
            mov al, 0x0A
            int 0x10
            cmp si, di
            je hp1_end
            jmp hp1_loop
        hp1_end:
            ret
        times 1408 - ($-$$) db 0
    _cmddata7:
        db 'r'
        db 'e'
        db 'a'
        db 'd'
        db '.'
        db 'l'
        db 'b'
        db 'c'
        db 0
        hp2_start:
            mov di, 0x8409
            int 0x62
            cmp cx, 1
            je hp2_no
            add cx, 9 ; FSPAR file name length (+1)
            mov si, cx
            int 0x60
            jmp hp2_end
        hp2_no:
            mov si, hp2__msg
            int 0x60
        hp2_end:
            ret
        hp2__msg:
            db "Nonexistent file", 0x0D, 0x0A, 0
        times 1472 - ($-$$) db 0
    _cmddata8:
        db 'f'
        db 't'
        db 'y'
        db 'p'
        db '.'
        db 't'
        db 'x'
        db 't'
        db 0
        db ".lbc: Bytecode. exec: yes", 0x0D, 0x0A, ".txt: Text. exec: no", 0x0D, 0x0A, 0
        times 1536 - ($-$$) db 0
        
times 2048 - ($-$$) db 0
