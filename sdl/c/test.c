/*This source code copyrighted by Lazy Foo' Productions (2004-2015)
and may not be redistributed without written permission.*/

//Using SDL and standard IO
#include <SDL2/SDL.h>
#include <stdio.h>

//enum {
//    A = 1,
//    B = 2,
//    C = 3
//} Test_Enum;
//
//typedef struct Type1 {
//    int type;
//    char c;
//} Type1;
//
//typedef struct Type2 {
//    int type;
//    float f;
//} Type2;
//
//typedef union Test {
//    int type;
//    Type1 type1;
//    Type2 type2;
//    Uint8 padding[20];
//} Test;

int main()
{
    char *format = "%d - %d\n";
    char output[30];
    sprintf(output, format, 3, 3);
    //printf(output);
    if (fwrite(output, 1, strlen(output), stdout) != strlen(output)) {
       perror("fwrite");
       return;
    }

    SDL_Surface* gHelloWorld;
    gHelloWorld = SDL_LoadBMP( "character.bmp" );
    if ( gHelloWorld == NULL ) {
        printf( "Well shit...%s\n", SDL_GetError() );
        return;
    }

    int32_t a = -10;
    uint32_t b = 5;
    
    uint32_t c = a-b;

    printf("t3h result:        %d\n", c);

    //printf("ref enum:          %d\n", A);
    printf("gHelloWorld:       %p\n", &gHelloWorld);
    printf("gHelloWorld:       %p\n", (void *)gHelloWorld);
    printf("flags:             %p\n", &(gHelloWorld->flags));
    printf("format:            %p\n", &(gHelloWorld->format));
    printf("w:                 %p\n", &(gHelloWorld->w));
    printf("w:                 %d\n", gHelloWorld->w);
    printf("h:                 %p\n", &(gHelloWorld->h));
    //printf("pitch:             %p\n", &(gHelloWorld->pitch));
    //printf("userdata:          %p\n", &(gHelloWorld->userdata));
    //printf("locked:            %p\n", &(gHelloWorld->locked));
    //printf("lock_data:         %p\n", &(gHelloWorld->lock_data));
    //printf("clip_rect:         %p\n", &(gHelloWorld->clip_rect));
    //printf("map:               %p\n", &(gHelloWorld->map));
    //printf("refcount:          %p\n", &(gHelloWorld->refcount));
    //printf("\n");

    //// http://stackoverflow.com/questions/21128092/d-expects-argument-of-type-int-but-argument-2-has-type-long-unsigned-int
    //printf("sizeof flags:      %zu\n", sizeof(gHelloWorld->flags));
    //printf("sizeof w:          %zu\n", sizeof(gHelloWorld->w));
    //printf("sizeof int:        %zu\n", sizeof(int));
    //printf("sizeof SDL_Event:  %zu\n", sizeof(SDL_Event));
    //printf("\n");

    //Test t;
    //t.type = 1;
    //t.type1.c = 'c';

    //printf("type:              %d\n", t.type);
    //printf("c:                 %c\n", t.type1.c);
    //printf("&t:                %p\n", &t);
    //printf("&t.type:           %p\n", &t.type);
    //printf("&t.type1.c:        %p\n", &t.type1.c);

    //t.type = 2;
    //t.type2.f = 1.02;

    //printf("type:              %d\n", t.type);
    //printf("f:                 %.3f\n", t.type2.f);
    //printf("&t:                %p\n", &t);
    //printf("&t.type:           %p\n", &t.type);
    //printf("&t.type2.f:        %p\n", &t.type2.f);

    //printf("&t.type1.c (corrupt): %c\n", t.type1.c);

	//return 0;
}
