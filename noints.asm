bits 16
org 0x7c00
; text mode is 80x25
section .text
    main:
        ;mov si, string
        ;mov di, 1
        ;call writebyte
        ;
        ;mov bl, 0x51
        ;mov bh, 6
        ;mov di, 4
        ;call writebyte
        ;
        ;call getcursorposition
        ;
        ;mov bl, 0x51
        ;mov bh, 6
        ;mov di, ax
        ;call writebyte
        ;
        ;call getcursorposition
        ;
        ;add ax, 1
        ;
        ;call setcursorposition
        xor bl, bl
        call clearscreen
        
        call getcursorposition
        sub ax, 3
        call setcursorposition
        ;xor di, di
        ;mov si, string
        ;call writebytes
        ;mov ax, 0x0D
        ;call setcursorposition
    main.1:
        ;mov ax, 6
        ;call waitt
        ;mov ax, 0xFFFF
        ;call setcursorposition
        ;jmp main.1
    exit:
        cli
        hlt
    string:
        db "Hello, world!", 0x0
    movecursorup:
        ; Moves the cursor up 1 "step". Modifies the AL, BX, and DX registers.
        call getcursorposition
        
        sub ax, 80
        
        call setcursorposition
        ret
    movecursordown:
        ; Moves the cursor down 1 "step". Modifies the AL, BX, and DX registers.
        call getcursorposition
        
        add ax, 80
        
        call setcursorposition
        ret
    movecursorleft:
        ; Moves the cursor left 1 "step". Modifies the AL, BX, and DX registers.
        call getcursorposition
        
        sub ax, 1
        
        call setcursorposition
        ret
    movecursorright:
        ; Moves the cursor right 1 "step". Modifies the AL, BX, and DX registers.
        call getcursorposition
        
        add ax, 1
        
        call setcursorposition
        ret
    clearscreen:
        ; Clears the screen (in text mode). Expects BL to be the attributes (color attributes). (This function spills over into clearscreenmid and clearscreenend). Modifies the AX, ES, and DI registers.
        mov ax, 0xb800
        mov es, ax
        xor di, di
    clearscreenmid:
        mov [es:di], byte 32
        inc di
        mov [es:di], bl
        
        cmp di, 2000
        je clearscreenend
        
        inc di
        jmp clearscreenmid
    clearscreenend:
        ret
    waitt:
        ; Waits for an amount of time ~= (AX * 55 milliseconds). (This function spills over into waitmid and waitend). Modifies the BX register. AX register may change.
        xor bx, bx
    waitmid:
        hlt
        cmp bx, ax
        je waitend
        inc bx
    waitend:
        ret
    setcursorposition:
        ; Sets the cursor position (character position), expecting the cursor position to be in AX. Modifies the AL, BX, and DX registers.
        mov bx, ax

        mov dx, 0x3d4
        mov al, 0x0e
        out dx, al

        mov dx, 0x3d5
        mov al, bh
        out dx, al

        mov dx, 0x3d4
        mov al, 0x0f
        out dx, al

        mov dx, 0x3d5
        mov al, bl
        out dx, al
        ret
    getcursorposition:
        ; Gets the cursor position (character position) and stores it in AX. Does not modify the cursor or video memory. Modifies the AX and DX registers.
        mov dx, 0x3d4
        mov al, 0x0e
        out dx, al
        
        mov dx, 0x3d5
        in al, dx
        mov ah, al
        
        mov dx, 0x3d4
        mov al, 0x0f
        out dx, al
        
        mov dx, 0x3d5
        in al, dx
        ret
    writebyte:
        ; Writes a single byte of data to the character position in the DI register. Expects BL to be the character code and BH to be the attributes. Modifies the AX, ES, and DI registers.
        add di, di
        mov ax, 0xb800
        mov es, ax
        mov [es:di], bl
        add di, 1
        mov [es:di], bh
        ret
    writebytes:
        ; Writes multiple bytes as a zero-terminated string. Max string length = 2 ^ 16 Expects DI to be the character position and SI to be a memory address pointing to the zero-terminated string. (This function spills over into writebytesmid and writebytesend). Modifies the AX, BX, ES, GS, and DI registers.
        add di, di
        xor ax, ax
        mov gs, ax
        mov ax, 0xb800
        mov es, ax
    writebytesmid:
        mov bx, [gs:si]
        
        mov [es:di], bx
        inc di
        mov [es:di], byte 7
        inc di
        
        cmp bx, 0
        je writebytesend
        
        inc si
        jmp writebytesmid
    writebytesend:
        ret
