;BITS 32
;lea eax,[eax+edi+2]
BITS 64

segment .data
    NUM dd 0

segment .text

leave
ret
jnz LBL
mov al, 4
call FAKE
LBL:
FAKE:
ret
jz FAKE
jle FAKE
jge FAKE
jz $+2
add rax, 1
add [NUM], eax
sub [NUM], eax
add DWORD [NUM], 1
add BYTE [NUM], r9b
add DWORD [NUM], r9d
sub DWORD [NUM], r9d
sub [NUM], r9
jmp FAKE
or BYTE [NUM], 1
mov rax, 1
neg DWORD [NUM]
xor rax, rax
ret

;mov rax, rax
;mov rdx, rdx
;call FAKE
;jz FAKE
;mov r10, r10
;FAKE:
;mov rsi, rsi
