    BITS 16

start:
    mov ax, 07C0h       ; Set up 4K stack space after this bootloader
    add ax, 288     ; (4096 + 512) / 16 bytes per paragraph
    mov ss, ax
    mov sp, 4096

    mov ax, 07C0h       ; Set data segment to where we're loaded
    mov ds, ax

    mov ah , 0x02 ; BIOS read sector function
    mov al , 0x01
    mov ch , 0x00 ;
    mov dh , 0x00 ; Select head 0
    mov cl , 0x02 ; Start reading from second sector ( i.e.
    ; after the boot sector )

    mov bx, ds          ; Set ES:BX to point to our buffer (see end of code)
    mov es, bx
    mov bx, program

    int 0x13
    
    jnc .supported

.not_supported:
    jmp .end

.supported:
    call program
    jmp .end

.end:
    jmp $

    times 510-($-$$) db 0   ; Pad remainder of boot sector with 0s
    dw 0xAA55       ; The standard PC boot signature







program:
    mov si, text_string ; Put string position into SI
    call print_string   ; Call our string-printing routine
    ret

print_string:           ; Routine: output string in SI to screen
    mov ah, 0Eh     ; int 10h 'print char' function

.repeat:
    lodsb           ; Get character from string
    cmp al, 0
    je .done        ; If char is zero, end of string
    int 10h         ; Otherwise, print it
    jmp .repeat

.done:
    ret

    text_string db 'This is my cool new OS!', 0
