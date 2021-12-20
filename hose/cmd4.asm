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
        
        push 0
        pop es
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
 ; copies SI to BX for DX bytes.

; Actual code
; 0x7C00-0x7E00: bootloader location
; 0x7E00-0x8000: bootsector location
; 0x8400-0x8500: keyboard buffer location (256 byte length)
; 0x8A00-0x8E00: stack location (1 kb, 2 sectors)
; 0x9000-0x9800: programs are loaded here- program memory (2 kb, 4 sectors)
; 0x9800-0xA000/0xA800: guaranteed 0 bytes for at least 2 kB (4 kB max)
; 0xA800-0xB800: filesystem location (8 sectors, 4 kB)
; interrupt 0x60: print zero-terminated string. pointer in SI.
; interrupt 0x61: compare two strings, SI and BX pointers. Compare for DX bytes. Stops if the next character is AH (not a pointer) and AL is set to 1.
; interrupt 0x62: gives a pointer to the file named DI (8 byte pointer). CX is set to 1 if the file doesn't exist. If the file does exist, CX will be set to a pointer to the file.
; interrupt 0x63: finds the length of a zero-terminated string, given a pointer to it in SI. Returns length in AX. Does not modify any general-purpose registers except for AX. If BL is set to 1, expects string to be terminated by BH (not a pointer)
; interrupt 0x64: gives a pointer to command line arguments in SI, depending on the length of the command last executed. CX is set to 1 if command line arguments do not exist.
    .init:
        mov ax, printstring
        push 0
        pop es
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
        
        mov ax, strlen
        mov di, 0x18C
        mov [es:di], al
        inc di
        mov [es:di], ah
        
        mov ax, getcmdargsp
        mov di, 0x190
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
        push 0
        pop es
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
        add cx, 128 ; FSPAR file length
        mov si, cx
        mov cx, 0x9000
        push si
        push dx
        mov bx, cx
        mov si, 0x9800
        mov dx, 0x400 ; FSPAR filesystem length
        call memcpy
        pop dx
        pop si
        
        sub si, 115 ; FSPAR file body length
        mov bx, cx
        mov dx, 115 ; FSPAR file body length
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
        xor ax, ax
        mov [_kbdbufferlen], byte 0
    .kbdbufferflushmid:
        mov [es:bx], byte 0
        inc ax
        inc bx
        cmp ax, 256 ; the max length of the keyboard buffer
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
	    push 0
	    pop es
    strcmp1: ; compares BX to SI for DX bytes. If next character is AH (non-pointer) and AL is set to 1, returns 1. If they are inequal returns 0. Return value will be placed in AL. CHANGES SI, DX, CX, BX, and AX!
        mov cl, [es:bx]
        mov ch, [es:si]
        or dx, dx
        jz strcmp2
        cmp cl, ah
        je strcmp4
        cmp ch, ah
        je strcmp4
    strcmpcont:
        cmp cl, ch
        jne strcmp3
        inc bx
        inc si
        dec dx
        jmp strcmp1
    strcmp4:
        cmp al, 1
        jne strcmpcont
        mov al, 1
        iret
    strcmp2:
        mov al, 1
        iret
    strcmp3:
        xor al, al
        iret
    memcpy:
	    push 0
	    pop es
    memcpy1: ; copies SI to BX for DX bytes.
        mov cl, [es:si]
        mov [es:bx], cl
        or dx, dx
        jz memcpy2
        inc bx
        inc si
        dec dx
        jmp memcpy1
    memcpy2:
        ret
    getfilepointer: ; gives a pointer to the file named DI. CX is set to 1 if the file doesn't exist. If the file does exist, CX will be set to a pointer to the file.
        mov si, 0xA800
        push si
        add si, 0x400 ; FSPAR filesystem length
        mov bx, si
        pop si
    getfilepointer1:
        push bx
        push si
        mov bx, di
        mov dx, 12 ; FSPAR file name length
        mov ax, 0x2001
        int 0x61
        pop si
        pop bx
        cmp al, 1
        je getfilepointer3
        cmp bx, si
        je getfilepointer2
        add si, 128 ; FSPAR file length
        jmp getfilepointer1
    getfilepointer2:
        mov cx, 1
        iret
    getfilepointer3:
        mov cx, si
        iret
    strlen:
        xor ax, ax
        mov es, ax
        cmp bl, 1
        je strlen3
        mov bx, si
    strlen1:
        cmp [es:bx], byte 0
        je strlen2
        inc ax
        inc bx
        jmp strlen1
    strlen2:
        ; AX is already set
        iret
    strlen3:
        mov dl, bh
        mov bx, si
    strlen5:
        cmp [es:bx], dl
        je strlen2
        inc ax
        inc bx
        jmp strlen5
    getcmdargsp:
        mov si, 0x8400
        push 0
        pop es
        mov bl, 1
        mov bh, 0x20
        int 0x63
        add ax, 0x8401
        mov si, ax
        cmp ax, 0x8500
        ja getcmdargsp2
        xor cx, cx
        iret
    getcmdargsp2:
        mov cx, 1
        iret
    _kbdbufferlen:
        db 0
    _msg1:
        db "LICH started.", 0x0D, 0x0A, 0
    _msg2:
        db "cmd@A:> ", 0
    _msg3:
        db "Command not found.", 0x0D, 0x0A, 0
times 1024 - ($-$$) db 0
