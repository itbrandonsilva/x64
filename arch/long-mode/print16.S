BITS 16     ;Tells the assembler that its a 16 bit code
ORG 0x7C00  ;Origin, tell the assembler that where the code will
            ;be in memory after it is been loaded

mov ax, 0x1afd
call PRINT_INT16
call PRINT_NL

mov ax, 0xa1fd
call PRINT_INT16
call PRINT_NL

mov ax, 0xba0d
call PRINT_INT16
call PRINT_NL

mov ax, 0xc10d
call PRINT_INT16
call PRINT_NL

jmp $

PRINT_INT16:
    push bp
    mov bp, sp
    sub sp, 2

    xor bx, bx
    mov [bp-2], ax

    mov bl, ah
    call PRINT_INT8

    mov ax, [bp-2]
    mov bl, al
    call PRINT_INT8

    leave
    ret

PRINT_INT8:
    push bp
    mov bp, sp
    sub sp, 1

    mov [bp-1], bl
    mov bl, [bp-1]

    shr bl, 4
    call PRINT_INT4

    mov bl, [bp-1]
    and bl, 0xF
    call PRINT_INT4

    leave
    ret

; Converts a 4 bit integer into a character code
PRINT_INT4:
    add bl, 0x30
    cmp bl, 0x39
    jle .PRINT
    add bl, 0x7
.PRINT:
    call PRINT_CHAR
    ret

PRINT_CHAR:
    mov al, bl
    mov ah, 0x0E    ; Tell BIOS that we need to print one charater on screen
    mov bh, 0x00    ; Page no.
    mov bl, 0x07    ; Text attribute 0x07 is lightgrey font on black background

    int 0x10        ; Call video interrupt
    ret

PRINT_NL:
    mov bl, 0x0d ; carriage return
    call PRINT_CHAR
    mov bl, 0x0a ; line feed
    call PRINT_CHAR
    ret


;TIMES 510-($-$$) db 0  ; Fill the rest of sector with 0
;DW 0xAA55              ; Add boot signature at the end of bootloader
