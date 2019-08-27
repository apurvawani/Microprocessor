%macro Print 04
	mov rax , %1        ;%no is always in increasing order to denote position of the sequence of parameters
	mov rdi , %2
	mov rsi , %3
	mov rdx , %4
	syscall
%endmacro

%macro AtoH 04

	mov rdx, 00h		; stores final hex value
	mov byte[count], %1	; value of count is always final no of digits in hex value => obvio dx has to be rotated
	mov rdi, %2
%3:	
	rol rdx, 04h
	mov al, byte[rdi]
	cmp al, 39h
	jbe %4
	sub al, 07h
%4:	
	sub al, 30h
	mov ah, 00h		; so that higher ah value doesn't add to dx which will be storing final hex value
	add edx, eax
	inc rdi
	dec byte[count]
	jnz %3
	mov [%2] , edx		; store final hex value at memory location where initial ascii was present

%endmacro

%macro HtoA 01
	mov byte[count] , %1
	mov rsi , loc2
UP:	rol ebx , 04h
	mov al , bl
	AND al , 0Fh
	CMP al , 09h
	JBE NEXT
	ADD al ,07h
NEXT:	ADD al , 30h
	mov byte[rsi] , al
	INC rsi
 	DEC byte[count]
	JNZ UP
%endmacro

section .bss
	count resb 2
	loc resb 8
	loc2 resb 8
	choice resb 2
	
section .data
	menu1: db 10, "1->Hex To BCD",10,
	Mlen1: equ $-menu1
	menu2: db "2->BCD To Hex",10,
	Mlen2: equ $-menu2
	menu3: db "3->Exit",10
	Mlen3: equ $-menu3
	msg1: db "Enter 4-digit Hexadecimal number",10
	len1:equ $-msg1
	msg2: db "Enter 5-digit BCD number",10
	len2:equ $-msg2
	
section .text
global _start
_start:
list:	Print 1,1,menu1, Mlen1
	Print 1,1,menu2, Mlen2
	Print 1,1,menu3, Mlen3
	Print 0,0,choice, 2
	
	mov al, [choice]
	sub al, 30h
	CMP al, 01h
	JE HtoB
	CMP al, 02h
	JE BtoH
	CMP al, 03h
	JE exit
	;jmp list
	
HtoB:	Print 1,1, msg1, len1
	Print 0,0, loc, 8
	
	AtoH 04h, loc, UP1, DOWN1
	
	mov bx, [loc]
	mov byte[count], 00h
	mov rax, 00h
	mov ax, bx	; move dividend to ax from bx
	mov bx, 0Ah	; move divisor to bx ie 0A
up2:	mov rdx, 00h
	DIV bx		; after div quotient remains in ax but remainder is in dx
	push dx		; push remainder onto stack
	inc byte[count] ; to keep a count of how many values r pushed onto stack so that only that no of times we will keep poping out of stack
	cmp ax, 00h	; keep comparing if quotient is 0 cuz that becomes ur divisor in nxt turn
	jne up2
	mov byte[loc],00h
	mov rdx, 00h		
up3:	pop dx
	add dx, 30h	; convert to hex
	mov [loc] , edx
	Print 1,1, loc, 1
	dec byte[count]
	jnz up3
	jmp list
	
BtoH:	mov rbx, 00h
	mov rdx, 00h
	mov rcx ,00h
	mov rax ,00h
	Print 1,1, msg2, len2
	Print 0,0, loc2, 8
	
	AtoH 05h, loc2, UP2,DOWN2
	
	mov rbx, 00h
	mov rdx, 00h
l1:	mov rcx ,00h
	mov rax ,00h
	mov rcx, [loc2]
	
l2:	mov rax, 00h
	mov al, cl	; cx contains 5 digit bcd value
	and al, 0fh	; now al contains last digit of cx 
	mov rbx, 01h	; pow(a,0)=1
	mul rbx		; result is stored in rax so rax is moved to [loc2]
	mov [loc2], rax ; 1st tym move
	ror ecx, 04h	; rotate right
	
l3:	mov rax, 00h
	mov al, cl	; now al contains 2nd last digit of bcd 
	and al, 0fh
	mov rbx, 0ah	; pow(a,1)=a
	mul rbx
	add [loc2], rax ; NOTE :-> keep adding to [loc2] n not moving to loc2
	ror ecx, 04h
	
l4:	mov rax, 00h
	mov al, cl
	and al, 0fh
	mov rbx, 64h	; pow(a,2)=a
	mul rbx
	add [loc2], rax
	ror ecx, 04h
	
l5:	mov rax, 00h
	mov al, cl
	and al, 0fh
	mov rbx, 3E8h	; pow(a,3)=a
	mul rbx	
	add [loc2], rax
	ror ecx, 04h

	
l6:	mov rax, 00h
	mov al, cl
	and al, 0fh
	mov rbx, 2710h	; pow(a,4)=a
	mul rbx		; thus :->  rax had face value and rbx had powers of a
	add [loc2], rax
	
l7:	ror ecx, 04h
	
	mov rbx, 00h
	mov rbx, [loc2]
	HtoA 08h
	mov rsi , loc2
	;inc rsi
	;inc rsi
	;inc rsi
	;inc rsi
	Print 1,1,rsi,8
	jmp list
	
exit:	mov rax, 60
	mov rdi, 0
	syscall
	



	
	
