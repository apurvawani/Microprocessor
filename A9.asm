;Write x86 ALP to find the factorial of a given integer number on ;a command line without recursion.  
;Explicit stack manipulation is expected in the code.

%macro print 04
	mov rax,%1
	mov rdi,%2
	mov rsi,%3
	mov rdx,%4
	syscall
%endmacro


section .data
 
	msg1: db 'Entered number is: ',0xa
	len1: equ $-msg1

	msg2: db 'Factorial of Number is:',0xa
	len2: equ $-msg2
	count db 0
	newline: db 0x0A

section .bss
	num resb 03	 ; for ascii input from user 
	result resb 08   ; for ascii output 

section .text

	global _start
	_start:

	xor rax,rax
	xor rbx,rbx
	xor rcx,rcx
	xor rdx,rdx

	pop rbx			;Remove number of arguments
	pop rbx			;Remove the executable program name
	pop rbx			;Remove the actual number whose factorial is to be calculated (Address of number)
	mov [num], rbx
	call ATOH
	
	print 1,1,msg1,len1
	print 1,1,[num],03	
	print 1,1,newline,1
	
up:
	inc byte[count]
	push bx		; in case of 1! 1 will be pushed to stack then decremented to 0 but 0 not greater than 1 we move ahead in code 
	dec bx		; n becomes (n-1)
	cmp bx,01h
	jg up		; jmp if greater
	
	mov ax,01H	
	xor rbx,rbx

	

A:
	
	pop bx
	mul bx	; multiplicand shld be in ax during mul instruction 
	dec byte[count]
	jnz A
	mov rbx,rax

	print 1,1,msg2,len2
	
	call HTOA

	mov rax,60
	mov rdi,0
	syscall
	

ATOH:                                          ;; ASCII to Hex conversion
	xor rbx,rbx
	xor rcx,rcx
	xor rax,rax

	mov rcx,02
	mov rsi,num			
	up1:
	rol bx,04

	mov al,[rsi]
	cmp al,39h
	jbe p1

	sub al,07h

	p1: 
	sub al,30h
	add bl,al
	inc rsi
	loop up1
ret

HTOA:
	                    			; Hex to ASCII conversion
	mov rcx,8				; count is always equal to no of digits in hex value 
	mov rdi,result
	dup1:
	rol ebx,4				; ebx => max 8 digits displayed
	mov al,bl
	and al,0fh
	cmp al,09h
	jbe p3
	add al,07h
	;jmp p4
	p3: add al,30h
	p4:mov [rdi],al
	inc rdi
	loop dup1

	print 1,1,result,08
	
ret



;******output******
;[student@localhost]$ nasm -f elf64 ass9.asm
;[student@localhost]$ ld -o ass9 ass9.o
;[student@localhost]$ ./ass9 05
;Entered number is: 05
;Factorial of Number is:
;00000078[student@localhost]$ 



