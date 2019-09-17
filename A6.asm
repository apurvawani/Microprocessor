%macro Print 04
	mov rax , %1        ;%no is always in increasing order to denote position of the sequence of parameters
	mov rdi , %2
	mov rsi , %3
	mov rdx , %4
	syscall
%endmacro

%macro HtoA 03
	mov ax, 00h
	mov byte[count] , 04h	; 4 digits of hex 
	mov rsi , %1
%2:	rol bx , 04h
	mov al , bl
	AND al , 0Fh
	CMP al , 09h
	JBE %3
	ADD al ,07h
%3:	ADD al , 30h
	mov byte[rsi] , al
	INC rsi
 	DEC byte[count]
	JNZ %2
%endmacro

section .data
	msg1: db "In protected mode" , 10
	len1: equ $-msg1
	
	msg2: db "Not in protected mode" , 10
	len2: equ $-msg2
	
	msg3: db "Contents of GDTR : "
	len3: equ $-msg3
	
	msg4: db "Contents of LDTR : "
	len4: equ $-msg4
	
	msg5: db "Contents of IDTR : "
	len5: equ $-msg5
	
	msg6: db "Contents of TR : "
	len6: equ $-msg6
	
	msg7: db "Contents of MSW : "
	len7: equ $-msg7
	
	msg8: db 10
	len8: equ $-msg8
	
	msg9: db ":"
	len9: equ $-msg9
	
	msg10: db "Contents of MSW : "
	len10: equ $-msg10
		
section .bss
	msw: resw 1
	gdtr: resd 1			; resd + resw = 6 bytes ie 12 digits
	      resw 1
      	idtr: resd 1
      	      resw 1
	ldtr: resw 1
	tr: resw 1
	loc: resb 4
	count: resb 2
	
section .text
global _start

_start:
	SMSW [msw]			; store MSW 
	mov ax , [msw]			; MSW is 16 bits
	BT ax , 0			; lsb of MSW is PE bit ie protection enable if PE=1 then protection enabled else disabled 
	JC next
	Print 1 , 1 , msg2 , len2
	JMP exit
next:	Print 1 , 1 , msg1 , len1
	
 	XOR rbx , rbx			; variable gdtr is 32+16 = 48 bits(6 bytes) and rbx is 64 bits
 	SGDT [gdtr]			; store gdtr with value of [GDT]
 	Print 1 , 1 , msg3 , len3
 	mov bx , word[gdtr+4]		; lowest 1 word in bx cuz location to location transfer not allowed
 	mov [loc] , bx
 	HtoA  loc , l1 , l2
 	Print 1 , 1 , loc , 4		; 4 digits after hextoascii needs 4 bytes
 	
 	mov bx , word[gdtr+2]
 	mov [loc] , bx
 	HtoA  loc , l3 , l4
 	Print 1 , 1 , loc , 4
 	
 	Print 1 , 1 , msg9 , len9
 	
 	mov bx , word[gdtr]
 	mov [loc] , bx
 	HtoA  loc , l5 , l6
 	Print 1 , 1 , loc , 4 
 	Print 1 , 1 , msg8 , len8
 	
	SIDT [idtr]
 	Print 1 , 1 , msg5 , len5
 	
 	mov bx , word[idtr+4]
 	mov [loc] , bx
 	HtoA  loc , l7 , l8
 	Print 1 , 1 , loc , 4
 	
 	mov bx , word[idtr+2]
 	mov [loc] , bx
 	HtoA  loc , l9 , l10
 	Print 1 , 1 , loc , 4
 	
 	Print 1 , 1 , msg9 , len9
 	
 	mov bx , word[idtr]
 	mov [loc] , bx
 	HtoA  loc , l11 , l12
 	Print 1 , 1 , loc , 4
 	Print 1 , 1 , msg8 , len8
 	
 	SLDT [ldtr]
 	mov bx , word[ldtr]
 	mov [loc] , bx
 	HtoA loc , l13 , l14 
 	Print 1 , 1 , msg4 , len4
 	Print 1 , 1 , loc , 4 
 	Print 1 , 1 , msg8 , len8
 	
 	STR [tr]
 	mov bx , word[tr]
 	mov [loc] , bx
 	HtoA loc , l15 , l16
 	Print 1 , 1 , msg6 , len6
 	Print 1 , 1 , loc , 4 
 	Print 1 , 1 , msg8 , len8
 	
 	SMSW [msw]
 	mov bx , word[msw]
 	mov [loc] , bx
 	HtoA loc , l17 , l18
 	Print 1 , 1 , msg10 , len10
 	Print 1 , 1 , loc , 4 
 	Print 1 , 1 , msg8 , len8
 	
exit:	mov rax, 60
	mov rdi, 0
	syscall 
 	
