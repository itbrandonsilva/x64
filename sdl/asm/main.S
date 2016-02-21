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
    SDL_INIT_VIDEO      dd 0x20
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
    LOGO_SURFACE        dq 1
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
    RB                  db `rb`,0
    NL                  db `\n`,0
    NOINIT              db `SDL could not initialize. SDL_Error: %s\n`,0
    TITLE               db `SDL Tutorial`,0
    ERRNOCREATE         db `Window could not be created. SDL_Error: %s\n`,0
    NOLOADBMP           db `Could not load image...`,0
    spritePath          db `out/character.bmp`,0
    logoPath            db `out/sdl-logo.bmp`,0
    fontPath            db `out/FreeMonoBold.ttf`,0
    EXIT_MSG            db `Exiting...\n\n`,0
    SCORE_TEXT          db `%d - %d`,0


extern exit, printf, sprintf, getcwd, rand, srand, time
extern SDL_CreateWindow, SDL_Init, SDL_GetError, SDL_GetWindowSurface, SDL_MapRGB
extern SDL_FillRect, SDL_UpdateWindowSurface, SDL_Delay, SDL_DestroyWindow, SDL_Quit
extern SDL_RWFromFile, SDL_LoadBMP_RW, SDL_UpperBlit, SDL_PollEvent, SDL_FreeSurface
extern TTF_Init, TTF_Quit, TTF_OpenFont, TTF_RenderText_Solid ;, TTF_GetError (Is mapped to SDL_GetError in SDL_ttf.h)

global main
segment .text
main:
    push rbp
    mov rbp, rsp
    sub rsp, 64

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

    xor edi, edi
    mov rdi, [SDL_INIT_VIDEO]
    call    SDL_Init
    cmp rax, 0
    jl .error

    call TTF_Init
    cmp rax, 0
    jl .error

    call GAME_initFont
    mov rax, [G_FONT]
    cmp rax, 0
    jz .error

    call GAME_loadSurfaces
    cmp rax, 0
    jz .error

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
    call GAME_updateBall

    mov edi, 20
    call SDL_Delay
    call GAME_draw

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

    xor rax, rax
    leave
    call exit

GAME_exit:  
    mov rdi, EXIT_MSG
    xor rsi, rsi
    call printf
    mov BYTE [STATUS], 1
    ret

GAME_keyDown:
    call GAME_mapKey
    or BYTE [INPUTS], al
    ret

GAME_keyUp:
    call GAME_mapKey
    not al
    and BYTE [INPUTS], al
    ret

GAME_mapKey:
    cmp DWORD [SDLK_UP], edi
    jnz $+4
    mov al,8

    cmp DWORD [SDLK_DOWN], edi
    jnz $+4
    mov al,4

    cmp DWORD [SDLK_ESCAPE], edi
    jnz $+7
    call GAME_exit
    ret

GAME_handleInputs:
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
    xor rax, rax
    ret

GAME_updateBall:
    mov edx, [B_VX]
    add [BALL_RECT+SDL_Rect.x], edx
    mov edx, [B_VY]
    add [BALL_RECT+SDL_Rect.y], edx

    cmp DWORD [BALL_RECT+SDL_Rect.x], 0
    jge $+12
    call GAME_resetBall
    call GAME_scoreP2

    mov eax, [SCREEN_WIDTH]
    sub eax, [BALL_RECT+SDL_Rect.w]
    cmp DWORD [BALL_RECT+SDL_Rect.x], eax
    jle $+12
    call GAME_resetBall
    call GAME_scoreP1
    
    cmp DWORD [BALL_RECT+SDL_Rect.y], 0
    jge $+9
    neg DWORD [B_VY]

    mov eax, [SCREEN_HEIGHT]
    sub eax, [BALL_RECT+SDL_Rect.h]
    cmp DWORD [BALL_RECT+SDL_Rect.y], eax
    jle $+9
    neg DWORD [B_VY]
    xor rax, rax
    ret

GAME_scoreP1:
    inc BYTE [P1_SCORE]
    ret

GAME_scoreP2:
    inc BYTE [P2_SCORE]
    ret

GAME_draw:
    and rsp, -16

    mov rdi, [SCREEN_SURFACE]
    mov rdi, [rdi+8]
    mov rsi, 0
    mov rdx, 0
    mov rcx, 0
    call SDL_MapRGB

    mov rdi, [SCREEN_SURFACE]
    xor rsi, rsi
    mov rdx, rax
    call SDL_FillRect

    mov edi, [P1_X]
    mov esi, [P1_Y]
    call GAME_drawPaddle

    mov edi, [P2_X]
    mov esi, [P2_Y]
    call GAME_drawPaddle

    call GAME_drawBall
    call GAME_drawText
    call GAME_drawLogo

    mov rax, [WINDOW]
    mov rdi, rax
    xor rsi, rsi
    call SDL_UpdateWindowSurface

    add rsp, 8
    xor rax, rax
    ret

GAME_drawPaddle:
    and rsp, -16

    mov [PADDLE_RECT+SDL_Rect.x], edi
    mov [PADDLE_RECT+SDL_Rect.y], esi

    mov rdi, [SCREEN_SURFACE]
    mov rdi, [rdi+8]
    mov rsi, 255
    mov rdx, 255
    mov rcx, 255
    call SDL_MapRGB

    mov rdi, [SCREEN_SURFACE]
    mov rsi, PADDLE_RECT
    mov rdx, rax
    call SDL_FillRect

    add rsp, 8
    xor rax, rax
    ret

GAME_drawBall:
    and rsp, -16

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
    add rsp, 8
    ret

GAME_drawText:
    push rbp
    mov rbp, rsp
    sub rsp, 512

    lea rdi, [rbp-512]
    mov rsi, SCORE_TEXT
    xor rdx, rdx
    xor rcx, rcx
    mov dl, [P1_SCORE]
    mov cl, [P2_SCORE]
    call sprintf

    mov rdi, [G_FONT]
    lea rsi, [rbp-512]
    mov rdx, [G_FONT_COLOR]
    call TTF_RenderText_Solid

    mov [rbp-8], rax

    call GAME_getHalfScreenWidth
    mov r8d, eax

    mov rdi, [rbp-8]
    call GAME_getHalfSurfaceWidth
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

GAME_getHalfScreenWidth:
    xor rdx, rdx
    mov eax, [SCREEN_WIDTH]
    mov esi, 2
    idiv esi
    ret

GAME_getHalfSurfaceWidth:
    xor rdx, rdx
    mov eax, [rdi+16]
    mov esi, 2
    idiv esi
    ret

GAME_initBallSpeed:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    mov al, [BALL_SPEED]
    mov [rbp-16], al

    mov DWORD [B_VX], 0
    mov DWORD [B_VY], 0

    call rand
    and rax, 1
    cmp rax, 0
    mov bl, [rbp-16]
    jz $+9
    add [B_VX], ebx
    jnz $+9
    sub [B_VX], ebx 

    call rand
    and rax, 1
    cmp rax, 0
    mov bl, [rbp-16]
    jz $+9
    add [B_VY], ebx
    jnz $+9
    sub [B_VY], ebx

    xor al, al
    mov rdi, INT_MSG
    mov esi, [B_VX]
    call printf
    xor al, al
    mov rdi, INT_MSG
    mov esi, [B_VY]
    call printf

    xor rax, rax
    leave
    ret

GAME_resetBall:
    mov DWORD [BALL_RECT+SDL_Rect.x], 320
    mov DWORD [BALL_RECT+SDL_Rect.y], 240
    mov DWORD [BALL_RECT+SDL_Rect.w], 15
    mov DWORD [BALL_RECT+SDL_Rect.h], 15
    call GAME_initBallSpeed
    xor rax, rax
    ret

GAME_initFont:
    mov rdi, fontPath
    mov rsi, 30
    call TTF_OpenFont
    mov [G_FONT], rax
    xor rax, rax
    ret

GAME_drawLogo:
    push rbp
    mov rbp, rsp
    sub rsp, SDL_Rect_size

    call GAME_getHalfScreenWidth
    mov r8, rax
    mov rdi, [LOGO_SURFACE]
    call GAME_getHalfSurfaceWidth
    mov r9, rax
    sub r8, r9

    mov DWORD [rsp+SDL_Rect.x], r8d
    mov DWORD [rsp+SDL_Rect.y], 35
    mov DWORD [rsp+SDL_Rect.w], 0
    mov DWORD [rsp+SDL_Rect.h], 0

;   extern DECLSPEC int SDLCALL SDL_UpperBlit (SDL_Surface * src, const SDL_Rect * srcrect, SDL_Surface * dst, SDL_Rect * dstrect)
    mov rdi, [LOGO_SURFACE]
    mov rsi, 0
    mov rdx, [SCREEN_SURFACE]
    mov rcx, rsp
    call SDL_UpperBlit

    leave
    ret

GAME_loadSurfaces:
    and rsp, -16

    mov esi, RB
    mov edi, logoPath
    call SDL_RWFromFile
    mov rsi, 1;
    mov rdi, rax;
    call SDL_LoadBMP_RW

    add rsp, 8

    cmp rax, 0
    jnz $+3
    ret

    mov [LOGO_SURFACE], rax
    mov rax, 1
    ret
