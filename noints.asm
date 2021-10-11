bits 16
org 0x7c00

section .text
    main:
        mov si, string
        mov di, 1
        call writebytes
        
        mov bl, 0x51
        mov bh, 6
        mov di, 4
        call writebyte
        
        call getcursorposition
        
        mov bl, 0x51
        mov bh, 6
        mov di, ax
        call writebyte
        
        call getcursorposition
        
        add ax, 2
        
        call setcursorposition
    exit:
        cli
        hlt
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
        ; Writes multiple bytes as a zero-terminated string. Expects DI to be the character position and SI to be a memory addresss pointing to the zero-terminated string. (This function spills over into writebytesmid and writebytesend). Modifies the AX, BX, ES, GS, and DI registers.
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
    string:
        db "Hello, world!", 0x0
