segment .rodata
	RB      db "rb",0
	PATH    db "character.bmp",0
	ERR     db "Well shit...%s",0
	;RB      db "rb"
	;PATH    db "character.bmp"
	;ERR     db "Well shit...%s"

segment .text

extern printf
extern SDL_CreateWindow, SDL_Init, SDL_GetError, SDL_GetWindowSurface, SDL_MapRGB                                                  
extern SDL_FillRect, SDL_UpdateWindowSurface, SDL_Delay, SDL_DestroyWindow, SDL_Quit                                               
extern SDL_RWFromFile, SDL_LoadBMP_RW, SDL_UpperBlit  
global main

main:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	; mov	esi, OFFSET FLAT:.LC0	#,
	; mov	edi, OFFSET FLAT:.LC1	#,
	mov	esi, RB
	mov	edi, PATH

	call	SDL_RWFromFile
	mov	esi, 1
	mov	rdi, rax
	call	SDL_LoadBMP_RW
	mov	QWORD [rbp-8], rax
	cmp	QWORD [rbp-8], 0
	jne	.L2
	call	SDL_GetError
	mov	rsi, rax
	mov	edi, ERR
	mov	eax, 0
	call	printf
.L2:
	mov	eax, 0
	leave
	ret
