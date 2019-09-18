;Write X86 menu driven Assembly Language Program (ALP) to implement OS (DOS)
;commands TYPE, COPY and DELETE using file operations. User is supposed to provide
;command line arguments in all cases.

%macro Print 4
	mov rax , %1
	mov rdi , %2
	mov rsi , %3	
	mov rdx , %4
	syscall
%endmacro


section  .data
	msg1: db "File opened successfully!", 10
	len1: equ $-msg1

	msg2: db "Error in opening file!", 10
	len2: equ $-msg2


section  .bss
	fname: resb 10
	fname1: resb 10
	fname2: resb 10
	fd: resb 17		; file descriptor : 17 bytes
	buffer: resb 200
	fd1:resb 17
	fd2:resb 17


section  .text
global _start
_start:
		pop rbx            		;rbx contains number of arguments
		pop rbx	           		;rbx contains address of executeable file ie ./p
		pop rbx			   	;rbx contains operation to be performed i.e copy , delete , type  

		cmp byte[rbx] , 116
		je type
		cmp byte[rbx] , 99		; character is 1 byte
		je copy
		cmp byte[rbx] , 100
		je delete
		 
exit:		mov rax , 60
		mov rdi , 0
		syscall


type:		pop rbx				       ; actual filename
		CALL tc				       ; print file to console
		
		mov rax , 3                            ;closing file
		mov rdi , [fd]			       ;fname
		syscall
		
		jmp exit 
		 
		 
copy:		pop rbx
		CALL cc				; just copy file name n open that file
		pop rbx
		CALL c_x			; just copy file name n open that file
		Print 0 , [fd] , buffer , 200	; read from fname
		Print 1 , [fd1] , buffer , 13	; write to fname1
		
		mov rax , 3                  ;close fname
		mov rdi , [fd]
		syscall
		
		mov rax , 3                  ;close fname1
		mov rdi , [fd1]
		syscall
		
		JMP exit 
		 
		 
delete:		pop rbx
		CALL dc
		
		mov rax , 3                  ; closing file
		mov rdi , [fd2]		     ; fname2
		syscall
		
		JMP exit 
		 
		 
		 
tc:		mov rsi , fname			; copying file address which is now in rbx to variable fname byte by byte (msb to lsb)
						; cuz after next pop rbx will contain new value then
up:		mov dl , byte[rbx]		; cuz memory to memory transfer not allowed we have dl	
		mov byte[rsi] , dl
		inc rsi
		inc rbx
		cmp byte[rbx] , 0		; untill rbx becomes null
		jne up

		Print 2 , fname , 2 , 0777   	;after opening file kernel gives file descriptor value in rax
		mov qword[fd] , rax
		BT rax , 63
		jc next2
		
		Print 1 , 1 , msg1 , len1
		jmp next1
		
next2:		Print 1 , 1 , msg2 , len2
		jmp b1

next1: 		Print 0 , [fd] , buffer , 200		; read mode buffer now contains the entire buffer
		Print 1 , 1 , buffer , 200		; print that buffer on terminal (TYPE command)
b1:		RET
		
		
		
cc:		mov rsi , fname

up2:		mov dl , byte[rbx]
		mov byte[rsi] , dl
		inc rsi
		inc rbx
		cmp byte[rbx] , 0			;null value
		jne up2

		Print 2 , fname , 2 , 0777		; open file
		mov qword[fd] , rax
		BT rax , 63
		jc next4
		
		Print 1 , 1 , msg1 , len1
		jmp next5

next4:		Print 1 , 1 , msg2 , len2
next5:		RET



c_x:		mov rsi , fname1

up3:		mov dl , byte[rbx]
		mov byte[rsi] , dl
		inc rsi
		inc rbx
		cmp byte[rbx] , 0
		jne up3

		Print 2 , fname1 , 2 , 0777

		mov qword[fd1] , rax
		BT rax , 63
		jc next7
		
		Print 1 , 1 , msg1 , len1
		jmp next6

next7:		Print 1 , 1 , msg2 , len2
next6:		RET




dc:		mov rsi , fname2

up4:		mov dl , byte[rbx]
		mov byte[rsi] , dl
		inc rsi
		inc rbx
		cmp byte[rbx] , 0
		jne up4

		Print 2 , fname2 , 2 , 0777

		mov qword[fd2] , rax
		BT rax , 63
		jc next9
		
		Print 1 , 1 , msg1 , len1
		jmp next10

next9:		Print 1 , 1 , msg2 , len2
		jmp b2

next10: 	mov rax , 87		; to delete the file
		mov rdi , fname2
		syscall
b2:		RET


