;Write X86 program to sort the list of integers in ascending/descending order. Read the input
;from the text file and write the sorted data back to the same text file using bubble sort 

%macro Print 04
	mov rax , %1        ;%no is always in increasing order to denote position of the sequence of parameters
	mov rdi , %2
	mov rsi , %3
	mov rdx , %4
	syscall
%endmacro

section .data
	fname: 	db "database.txt" , 0
	msg1: 	db "File opened successfully!" , 10
	len1: 	equ $-msg1
	
	msg2: 	db "File not opened!" , 10
	len2: 	equ $-msg2	
	
	msg3: 	db "Data sorted successfully!" , 10
	len3: 	equ $-msg3
	
	msg4: 	db "count 1 "
	len4: 	equ $-msg4
	
	msg5: 	db "count 2 "
	len5: 	equ $-msg5

section .bss
	buffer:	 resb 200
	fd:	 resb 17
	cnt1:	 resb 2
	cnt2:	 resb 2
	cnt3:	 resb 2

section .text
global _start

_start:
	Print 2 , fname , 2 , 0777
	
	mov [fd] , rax
	BT rax , 63
	JNC status
	Print 1 , 1 , msg2 , len2
	jmp exit
	
status:	Print 1 , 1 , msg1 , len1

	Print 0 , [fd] , buffer , 200	; reading file
	mov [cnt1] , rax
	mov [cnt2] , rax
	mov [cnt3] , rax	; to maintain the file size as parameter while writing to the file
	DEC byte[cnt1]
	DEC byte[cnt2]
	
	mov rax , 3              ;closing file
        mov rdi , [fd]
        syscall
        
;sorting
		
	mov ax , [cnt2]		; [ax]= n-1
	mov rbx , 00h
	mov rcx , 00h
	
begin:	mov rsi , buffer	; for(int i=1; i<n; i++)	ie i goes from 1st element to 2nd last element ]-> both i n j run for n-1 times
	mov rdi , buffer+1	;	for(int j=i+1;j<n+1; j++)	ie j goes from i+1 till last element   ]
	mov [cnt1] , ax		; every loop for i , j is updated to n-1 ie in total inner loop runs for (n-1)(n-1) times
			  	; here rsi=i and rdi=j cnt1= count for j and cnt2 count for i
p:	mov bl , byte[rsi]
	mov cl , byte[rdi]
	CMP bl , cl
	JB next

swap:	mov [rsi] , cl
	mov [rdi] , bl

next:	INC rsi
	INC rdi
	DEC byte[cnt1]
	JNZ p

	DEC byte[cnt2]
	JNZ begin		; again move rsi to start element and rdi to rsi+1
 		
	Print 2 , fname , 2 , 0777	; opening file
	mov [fd] , rax
		
	Print 1 , [fd] , buffer , [cnt3]	; writing to file
	
	mov rax , 3              ;closing file
        mov rdi , [fd]
        syscall
        
	Print 1 , 1 , msg3 , len3
		
exit:	mov rax, 60
	mov rdi, 0
	syscall 

               
