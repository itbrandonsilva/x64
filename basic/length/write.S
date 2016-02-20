segment .data

msg:    db "Hello World",0x0a
len:    equ $-msg

extern write, exit

segment .text
global main
main:
    mov edx, len
    mov rsi, msg
    mov edi, 1
    call write
    xor edi,edi
    call exit
