; This is an assembly program meant to be compiled and run as a program in hose (cmd.asm).

; 0x8400: keyboard buffer location
; 0x7F60: filesystem location
; 0x9000: programs are loaded here
; 0x8E00: stack location
; interrupt 0x60: print zero-terminated string. pointer in SI.
; interrupt 0x61: compare two strings, SI and BX pointers. Compare for DX bytes.
; interrupt 0x62: gives a pointer to the file named DI (4 byte pointer). CX is set to 1 if the file doesn't exist. If the file does exist, CX will be set to a pointer to the file.

; program size reducing tips: int 0x62 has a pointer in SI as well as CX.

bits 16
org 0x9000

_main:
    mov di, 0x8405
    int 0x62

    cmp cx, 1
    jne yup
    mov ah, 0x0E
nope:
    jmp end
yup:
    int 0x60
end:
    mov ax, 0x0E0D
    int 0x10
    mov al, 0x0A
    int 0x10
    ret
