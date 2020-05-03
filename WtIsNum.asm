%define B_LENGTH 80 ;размер блока
%define STDOUT 0x0001 ;стандартный вывод

SECTION .text ;секции .data .text .bss
org 100h

	mov si, start_game_text ;получаем адрес памяти для функции lodsb
	call show	
start:	
	call compare
	
	mov ax,4C00h      
    int 21h

; должно быть число в ax
compare:	
.begin:	
	mov al, [end_n]
	mov bh, [begin_n]
	sub al,bh
	mov bl, 2
	xor ah,ah
	div bl
	add bh,al
	xchg bh,al
	xor ah,ah
	push ax
	call convert ;число должно быть в ax
.overror:
	mov si, this_is_it ;получаем адрес памяти для функции lodsb
	call show
	mov si, mass ;получаем адрес памяти для функции lodsb
	call show
	call read_symbol
	sub al,60
	cmp al,2
	ja .overror
	pop dx
	cmp al,0
	jz .below
	cmp al,2
	jz .over
	cmp al,1
	jz .equal
	
.over: ;ОШИБКА В ЛОГИКЕ 
	mov [begin_n],dl
	jmp .begin
.below:
	mov [end_n],dl
	jmp .begin
.equal:
	mov si, win ;получаем адрес памяти для функции lodsb
	call show
	ret

read_symbol:
	mov ah,1
	int 0x21 ; код символя будет в al < - 60 > - 62 = - 61
	mov si, new_line ;получаем адрес памяти для функции lodsb
	call show
	ret
	
; в bx записываем число до 255 в dx возвращается случайное число	
random:
    mov ax, 2C00h
    int 0x21
    mov ax,dx
    ;mov bx,0xff

    div bl

    xor ah,ah
    push dx
    mul bx
    pop dx
    sub dx,ax

	ret

convert:
	mov di, mass ;адрес для записи
	mov bx,10  ;база числа 10 или 16
	xor cx,cx
.loop1:	
    xor dx,dx  ;очищаем дх
    div bx     ;делим, остаток в дл
    add dl, '0' ;прибавляем 30 для перевода в асс2
    push dx     ;сохраняем число в стекик
    add cx,1    ;увеличиваем счетчик
    test ax,ax  ; проверяем на ноль
    jnz .loop1   ;циклируем
.revers:
    pop ax    ;выпихиваем число из стека
    stosb     ;записываем в ди из ал и прибавляем число
    loop .revers
    mov byte[di], 0
    ret
	
show:
	push ax
.print_next_char:
	lodsb
	or al, al
	jz .endShow
	mov dl,al ;закидываем данные из в
	mov ah, 0x02 ;функция дос вывод на дисплей
	int 0x21
	jmp .print_next_char
.endShow:
	pop ax
	ret
	
SECTION .data
	start_game_text db "This is game GUESS A NUMBER. Think of a number between 0 and 255 and I'll guess it! Are you redy? My first guess is: ",0x0d,0x0a,0 ;"This is game GUESS A NUMBER. Think of a number between 0 and 255 and I'll guess it! Are you redy? (y/n)",0,13
	win db "I,m WINNER!!!",13,10,0
	this_is_it db "This is it? Or it below/over? (<,=,>): ",0
	new_line db 13,10,0
	begin_n db 0
	end_n db 0xff
	 
SECTION .bss
	number RESB 1 ;число в один байт
	mass RESB 10
	


