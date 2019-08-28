%macro Print 04
	mov rax , %1        ;%no is always in increasing order to denote position of the sequence of parameters
	mov rdi , %2
	mov rsi , %3
	mov rdx , %4
	syscall
%endmacro

section .text
global space_cnt , newline_cnt , char_cnt				; these were extern in p1
extern cnt1 , cnt2 , cnt3 , s_count , n_count , ch_count , buffer , c	; these were global in p1
 
space_cnt:
	mov dx , 00h		; cuz we cannot directly initialise the memory location contents to 00h
	mov [s_count] , dx
	mov rsi , buffer
down:	mov al , byte[rsi]
	CMP al , 20h
	JNE up
	INC byte[s_count]
up:	INC rsi
	DEC byte[cnt1]
	JNZ down
	RET
	
newline_cnt:
	mov dx , 00h
	mov [n_count] , dx
	mov rsi , buffer
d:	mov al , byte[rsi]
	CMP al , 0x0A
	JNE u
	INC byte[n_count]
u:	INC rsi
	DEC byte[cnt2]
	JNZ d
	RET

char_cnt:
	mov dx , 00h
	mov [ch_count] , dx
	mov rsi , buffer
q:	mov al , byte[rsi]
	CMP al , [c]
	JNE p
	INC byte[ch_count]
p:	INC rsi
	DEC byte[cnt3]
	JNZ q
	RET
