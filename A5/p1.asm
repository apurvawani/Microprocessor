%macro Print 04
	mov rax , %1        ;%no is always in increasing order to denote position of the sequence of parameters
	mov rdi , %2
	mov rsi , %3
	mov rdx , %4
	syscall
%endmacro

%macro HtoA 03
	mov ax, 00h
	mov bx, [%1]		; bx contains hex value ie count of character
	mov byte[count] , 02h
	mov rsi , %1
%2:	rol bl , 04h		; 1st digit first converted to ascii
	mov al , bl		; bl used not bx cuz bl can occupy 2 digits (count of character may not exceed 2 digits)
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

%macro AtoH 03
	mov rdx, 00h
	mov byte[count], 01h
	mov rdi, %1
%2:	rol dx, 04h
	mov al, byte[rdi]
	cmp al, 39h
	jbe %3
	sub al, 07h
%3:	sub al, 30h
	mov ah, 00h
	add dx, ax
	inc rdi
	dec byte[count]
	jnz %2
	mov [%1] , dx
%endmacro

section .data
	fname: db "myText.txt" , 0			; filename defined
	msg1: db "File opened successfully!" , 10
	len1: equ $-msg1
	
	msg2: db "File not opened!" , 10
	len2: equ $-msg2
	
	msg3: db "Number of spaces = "
	len3: equ $-msg3
	
	msg4: db "Number of enters = "
	len4: equ $-msg4
	
	msg5: db 10
	len5: equ $-msg5
	
	msg6: db "Enter character : "
	len6: equ $-msg6
	
	msg7: db "Number of occurences of "
	len7: equ $-msg7
	
	msg8: db " = "
	len8: equ $-msg8
	
section .bss
global cnt1 , cnt2 , cnt3 , s_count , n_count , ch_count , buffer , c	; global => defined these variables in this file
	fd: resb 17		; why this high?? -> no reason but keep fd 17
	cnt1: resb 2
	cnt2: resb 2
	cnt3: resb 2
	s_count: resb 2
	n_count: resb 2
	ch_count: resb 2
	buffer: resb 200
	c: resb 1
	count: resb 2
	
section .text 
global _start			
extern space_cnt , newline_cnt , char_cnt	; these variables defined in p2

_start:
	mov rax , 2             ;opening file
	mov rdi , fname
	mov rsi , 2
	mov rdx , 0777
	syscall
	
	mov [fd] , rax			; kernel returns the file descriptor in rax
	BT rax , 63
	JNC status
	Print 1 , 1 , msg2 , len2	; should exit after this na??
	
status:	Print 1 , 1 , msg1 , len1
               
        Print 0 , [fd] , buffer , 200	   ; read mode of file  n [fd]-> file descriptor ie kind of pointer to file
        mov [cnt1] , rax                   ; rax contains actual file size returned by kernel 
        mov [cnt2] , rax		   ; cnt1=cnt2=cnt3 = to keep a count of how many times to increment rsi when rsi pointed to buffer 
        mov [cnt3] , rax
 	
        mov rax , 3              ; closing file cuz we now have the entire file in buffer
        mov rdi , [fd]
        syscall
        	       
        CALL space_cnt
        HtoA s_count , up1 , down1
        Print 1 , 1 , msg3 , len3
        Print 1 , 1 , s_count , 2
        
        Print 1 , 1 , msg5 , len5
        
        CALL newline_cnt
        HtoA n_count , up2 , down2
        Print 1 , 1 , msg4 , len4
        Print 1 , 1 , n_count , 2
        
        Print 1 , 1 , msg5 , len5
        
        Print 1 , 1 , msg6 , len6
        Print 0 , 0 , c , 1
        CALL char_cnt
        HtoA ch_count , up3 , down3
        Print 1 , 1 , msg7 , len7
        Print 1 , 1 , c , 1
        Print 1 , 1 , msg8 , len8
        Print 1 , 1 , ch_count , 2
        Print 1 , 1 , msg5 , len5
        
	
exit:	mov rax, 60
	mov rdi, 0
	syscall 
	

