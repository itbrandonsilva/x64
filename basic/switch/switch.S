segment .data
    switch:
            dq main.case0
            dq main.case1
            dq main.case2

    i       dq 1
    FORMAT  db `Result: %d\n`,0

extern printf

segment .text
global main
main:
    mov rax, [i]
    jmp [switch+8*rax]
    .case0:
        mov rsi, 1 
        jmp .end
    .case1:
        mov rsi, 10
        jmp .end
    .case2:
        mov rsi, 100
        jmp .end
    .end:
        mov rdi, FORMAT
        xor rax, rax
        xor rdx, rdx
        call printf
        xor rax, rax
        ret
