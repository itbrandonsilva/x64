;; sudo apt-get install libsdl2-dev libsdl2-ttf-dev
; Questions:
;   What determines the size of an int in gcc?
;   Clarify how struct alignment works when compiling a struct in C
;   Clarify instruction encoding
;   Figure out whether or not a stack frame is required by a function when using "call"
;   How does "extern" work
; Notes:
;   Another way to allocate space for a struc is by using "istruct SDL_RECT; iend"

struc SDL_Rect
    .x          resd 1
    .y          resd 1
    .w          resd 1
    .h          resd 1
endstruc

segment .data
    SDL_QUIT            dd 0x100
    SDL_KEYDOWN         dd 0x300
    SDL_KEYUP           dd 0x301

    SDLK_UP             dd 1073741906
    SDLK_DOWN           dd 1073741905
    SDLK_LEFT           dd 1073741904
    SDLK_RIGHT          dd 1073741903
    SDLK_ESCAPE         dd 27

    STATUS              db 0
    SCREEN_WIDTH        dd 640
    SCREEN_HEIGHT       dd 480
    WINDOW              dq 1
    SCREEN_SURFACE      dq 1
    SCORE_TEXT_SURFACE  dq 1
    EVENT               times 56 db 1
    G_FONT              dq 1
    G_FONT_COLOR        db 255, 255, 255, 0

    PADDLE_SPEED        db 5
    AI_PADDLE_SPEED     db 2
    BALL_SPEED          db 3

    INPUTS              db 0

    RANDOM              dq 0

    PADDLE_RECT         times SDL_Rect_size db 0
    BALL_RECT           times SDL_Rect_size db 0
    P1_SCORE            db 0
    P1_X                dd 20
    P1_Y                dd 100
    P2_SCORE            db 0
    P2_X                dd 610
    P2_Y                dd 100
    B_X                 dd 320
    B_Y                 dd 240
    B_VX                dd 0
    B_VY                dd 0

    CWD_STRING          times 200 db 0
    ERROR               db `Error: %s\n`,0
    INT_MSG             db `Value: %d\n`,0
    STR_MSG             db `%s\n`,0
    PTR_MSG             db `Pointer: %p\n`,0
    NOINIT              db `SDL could not initialize. SDL_Error: %s\n`,0
    TITLE               db `SDL Tutorial`,0
    ERRNOCREATE         db `Window could not be created. SDL_Error: %s\n`,0
    NOLOADBMP           db `Could not load image...`,0
    spritePath          db `out/character.bmp`,0
    fontPath            db `FreeMonoBold.ttf`,0
    EXIT_MSG            db `Exiting...\n\n`,0
    SCORE_TEXT          db `%d - %d`,0


extern printf, sprintf, getcwd, rand, srand, time
extern SDL_CreateWindow, SDL_Init, SDL_GetError, SDL_GetWindowSurface, SDL_MapRGB
extern SDL_FillRect, SDL_UpdateWindowSurface, SDL_Delay, SDL_DestroyWindow, SDL_Quit
extern SDL_RWFromFile, SDL_LoadBMP_RW, SDL_UpperBlit, SDL_PollEvent, SDL_FreeSurface
extern TTF_Init, TTF_Quit, TTF_OpenFont, TTF_RenderText_Solid ;, TTF_GetError (Is mapped to SDL_GetError in SDL_ttf.h)

global main
segment .text
main:
    push    rbp
    mov rbp, rsp
    sub rsp, 32

	; mov	DWORD PTR [rbp-20], edi	# argc, argc
	; mov	QWORD PTR [rbp-32], rsi	# args, args
    mov [rbp-20], edi
    mov [rbp-32], rsi

    ; Debug info
    mov rdi, CWD_STRING;
    mov rsi, 200;
    call getcwd
    mov rdi, STR_MSG;
    mov rsi, CWD_STRING;
    call printf;

    ; Seed rand
    xor rdi, rdi
    call time
    mov rdi, rax
    call srand

    ; Initialize PADDLE_RECT
    mov DWORD [PADDLE_RECT+SDL_Rect.w], 10
    mov DWORD [PADDLE_RECT+SDL_Rect.h], 130

    ; Initialize BALL_RECT
    call GAME_resetBall

    call GAME_initBallSpeed

    xor edi, edi
    mov rdi, 32 ; Brandon: SDL_INIT_VIDEO
    call    SDL_Init
    cmp rax, 0
    jl .error
    ; How does "test" work?
    ; test rax, rax

    call TTF_Init
    cmp rax, 0
    jl .error

    call GAME_initFont
    mov rax, [G_FONT]
    cmp rax, 0
    jz .error
    ;jmp .error


.initw:
    mov eax, [SCREEN_WIDTH]
    mov edx, [SCREEN_HEIGHT]
    mov r9d, 4
    mov r8d, edx
    mov ecx, eax
    mov edx, 536805376
    mov esi, 536805376

    mov edi, TITLE
    call    SDL_CreateWindow

    mov [WINDOW], rax
    cmp QWORD [WINDOW], 0
    jne .inits
    jmp .error

.inits:
    mov rdi, [WINDOW]
    call    SDL_GetWindowSurface
    mov [SCREEN_SURFACE], rax;

.loop:
    cmp BYTE [STATUS], 1
    jz .exit

    call GAME_handleInputs

    mov edi, 20
    call SDL_Delay
    call GAME_draw

    ;mov rdi, INT_MSG
    ;xor rsi, rsi
    ;mov sil, [INPUTS]
    ;call printf

.events:
    cmp BYTE [STATUS], 1
    jz .exit

    mov rdi, EVENT
    call SDL_PollEvent

    cmp rax, 0
    jz .loop

    mov eax, [SDL_QUIT]
    cmp [EVENT], eax
    jz .exit

    mov eax, [SDL_KEYDOWN]
    ; SDL_KeyboardEvent, SDL_Keysym, SDL_Keycode
    mov edi, [EVENT+4+12+4]
    cmp [EVENT], eax
    jnz $+7
    call GAME_keyDown

    mov eax, [SDL_KEYUP]
    ; SDL_KeyboardEvent, SDL_Keysym, SDL_Keycode
    mov edi, [EVENT+4+12+4]
    cmp [EVENT], eax
    jnz $+7
    call GAME_keyUp

    jmp .events

.error:
    call SDL_GetError
    mov rdi, ERROR
    mov rsi, rax
    call printf

.exit:
    mov rdi, [WINDOW]
    call SDL_DestroyWindow
    call SDL_Quit
    call TTF_Quit

    leave
    xor rax, rax
    ret

GAME_exit:  
    push rbp
    mov rbp, rsp

    mov rdi, EXIT_MSG
    xor rsi, rsi
    call printf

    mov BYTE [STATUS], 1

    leave
    ret

GAME_keyDown:
    push rbp
    mov rbp, rsp

    call GAME_mapKey
    or BYTE [INPUTS], al

    leave
    ret

GAME_keyUp:
    push rbp
    mov rbp, rsp

    call GAME_mapKey
    not al
    and BYTE [INPUTS], al

    leave
    ret


GAME_mapKey:
    push rbp
    mov rbp, rsp

    cmp DWORD [SDLK_UP], edi
    jnz $+4
    mov al,8

    cmp DWORD [SDLK_DOWN], edi
    jnz $+4
    mov al,4

    cmp DWORD [SDLK_ESCAPE], edi
    jnz $+7
    call GAME_exit

    leave
    ret

GAME_handleInputs:
    push rbp    
    mov rbp, rsp

    xor r9, r9
    mov r9b, [PADDLE_SPEED]

    mov r8, [INPUTS]
    and r8, 4
    cmp r8, 0
    jz $+10
    add [P1_Y], r9d

    mov r8, [INPUTS]
    and r8, 8
    cmp r8, 0
    jz $+10
    sub [P1_Y], r9d

    mov edx, [B_VX]
    add [BALL_RECT+SDL_Rect.x], edx
    mov edx, [B_VY]
    add [BALL_RECT+SDL_Rect.y], edx

    cmp DWORD [BALL_RECT+SDL_Rect.x], 0
    jge $+9
    neg DWORD [B_VX]

    mov eax, [SCREEN_WIDTH]
    sub eax, [BALL_RECT+SDL_Rect.w]
    cmp DWORD [BALL_RECT+SDL_Rect.x], eax
    jle $+9
    neg DWORD [B_VX]
    
    cmp DWORD [BALL_RECT+SDL_Rect.y], 0
    jge $+9
    neg DWORD [B_VY]

    mov eax, [SCREEN_HEIGHT]
    sub eax, [BALL_RECT+SDL_Rect.h]
    cmp DWORD [BALL_RECT+SDL_Rect.y], eax
    jle $+9
    neg DWORD [B_VY]

    leave
    ret

GAME_draw:
    push    rbp
    mov rbp, rsp

    mov rdi, [SCREEN_SURFACE]
    mov rdi, [rdi+8]
    mov rsi, 0
    mov rdx, 0
    mov rcx, 0
    call    SDL_MapRGB

    mov rdx, rax
    mov rdi, [SCREEN_SURFACE]
    mov rsi, 0
    call    SDL_FillRect

    mov edi, [P1_X]
    mov esi, [P1_Y]
    call GAME_drawPaddle

    mov edi, [P2_X]
    mov esi, [P2_Y]
    call GAME_drawPaddle

    call GAME_drawBall
    call GAME_drawText

    mov rax, [WINDOW]
    mov rdi, rax
    xor rsi, rsi
    call    SDL_UpdateWindowSurface

    leave
    ret

GAME_drawPaddle:
    push    rbp
    mov rbp, rsp

    mov [PADDLE_RECT+SDL_Rect.x], edi
    mov [PADDLE_RECT+SDL_Rect.y], esi

    mov rdi, [SCREEN_SURFACE]
    mov rdi, [rdi+8]
    mov rsi, 255
    mov rdx, 255
    mov rcx, 255
    call    SDL_MapRGB

    mov rdi, [SCREEN_SURFACE]
    mov rsi, PADDLE_RECT
    mov rdx, rax
    call SDL_FillRect

    xor rax, rax
    leave
    ret

GAME_drawBall:
    push rbp
    mov rbp, rsp

    mov rdi, [SCREEN_SURFACE]
    mov rdi, [rdi+8]
    mov rsi, 255
    mov rdx, 255
    mov rcx, 255
    call    SDL_MapRGB

    mov rdi, [SCREEN_SURFACE]
    mov rsi, BALL_RECT
    mov rdx, rax
    call SDL_FillRect

    xor rax, rax
    leave
    ret

GAME_drawText:
    push rbp
    mov rbp, rsp
    sub rsp, 400

    lea rdi, [rbp-400]
    mov rsi, SCORE_TEXT
    xor rdx, rdx
    xor rcx, rcx
    mov dl, [P1_SCORE]
    mov cl, [P2_SCORE]
    call sprintf

    ;xor rax, rax
    ;mov rdi, STR_MSG
    ;lea rsi, [rbp-400]
    ;xor rdx, rdx
    ;call printf

    mov rdi, [G_FONT]
    lea rsi, [rbp-400]
    mov rdx, [G_FONT_COLOR]
    call TTF_RenderText_Solid

    mov [rbp-8], rax

    xor rdx, rdx
    mov eax, [SCREEN_WIDTH]
    mov esi, 2
    idiv esi
    mov r8d, eax

    mov rsi, [rbp-8]
    xor rdx, rdx
    mov eax, [rsi+16]
    mov esi, 2
    idiv esi

    sub r8d, eax

    mov [rbp-24], r8d
    mov DWORD [rbp-20], 0

    mov rdi, [rbp-8]
    mov rsi, 0
    mov rdx, [SCREEN_SURFACE]
    lea rcx, [rbp-24]
    call SDL_UpperBlit

    mov rdi, [rbp-8]
    call SDL_FreeSurface

    leave
    ret

GAME_initBallSpeed:
    push rbp
    mov rbp, rsp
    sub rsp, 1

    mov al, [BALL_SPEED]
    mov [rbp-1], al

    call rand
    and rax, 1
    cmp rax, 0
    mov bl, [rbp-1]
    jz $+9
    add [B_VX], ebx
    jnz $+9
    sub [B_VX], ebx 

    call rand
    and rax, 1
    cmp rax, 0
    mov bl, [rbp-1]
    jz $+9
    add [B_VY], ebx
    jnz $+9
    sub [B_VY], ebx

    xor rax, rax ; Segfaults without this?
    mov rdi, INT_MSG
    mov esi, [B_VX]
    call printf
    xor rax, rax ; Segfaults without this?
    mov rdi, INT_MSG
    mov esi, [B_VY]
    call printf

    xor rax, rax
    leave
    ret

GAME_resetBall:
    push rbp
    mov rbp, rsp

    mov DWORD [BALL_RECT+SDL_Rect.x], 320
    mov DWORD [BALL_RECT+SDL_Rect.y], 240
    mov DWORD [BALL_RECT+SDL_Rect.w], 15
    mov DWORD [BALL_RECT+SDL_Rect.h], 15

    leave
    ret

GAME_initFont:
    push rbp
    mov rbp, rsp

    mov rdi, fontPath
    mov rsi, 30
    call TTF_OpenFont

    mov [G_FONT], rax

    leave
    ret

;    jmp .LOAD_BMP

;.LOAD_BMP:
;    mov esi, rb
;    mov edi, spritePath
;    call SDL_RWFromFile
;    mov rsi, 1;
;    mov rdi, rax;
;    call SDL_LoadBMP_RW
;    cmp rax, 0
;    je .L17
;    jmp .L40
;.L17:
;    call SDL_GetError
;    mov rdi, rax
;    xor eax, eax
;    call printf
;    mov rdi, NL
;    call printf
;    jmp .exit

;        extern DECLSPEC int SDLCALL SDL_UpperBlit
;            (SDL_Surface * src, const SDL_Rect * srcrect,
;             SDL_Surface * dst, SDL_Rect * dstrect);

;.L40:
;    mov rdi, rax
;    mov rsi, 0
;    mov rdx, [SCREEN_SURFACE]
;    mov rcx, 0
;    call SDL_UpperBlit

