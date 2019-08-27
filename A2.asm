%macro Print 04
	mov rax , %1        ;%no is always in increasing order to denote position of the sequence of parameters
	mov rdi , %2
	mov rsi , %3
	mov rdx , %4
	syscall
%endmacro

%macro PrintBlock 02
	mov rsi , %1
	mov byte[count] , 5h    ;total nos in the array
	
%2:                              
	mov rbx , rsi 			;cuz we want rsi address to print and the content of rbx register is printed we copied rsi address to rbx
	push rsi
	CALL HtoA
	Print 1, 1, loc , 16		;print addr and loc has hex to ascii converted data to be printed
	Print 1, 1 , msg3 , len3	;print colon
	pop rsi
	
	mov rbx, qword[rsi]		;cuz we want rsi contents to print and the content of rbx register is printed we copied rsi content to rbx
	push rsi
	CALL HtoA
	Print 1, 1, loc , 16    	;print data
	Print 1, 1, msg4 , len4	        ;print newline
	pop rsi
	
	ADD rsi , 8h
	DEC byte[count]
	JNZ %2
%endmacro

global _start

HtoA :		       ; and for each no in array 16 digits are printed by calling HtoA 16 times
	mov cl , 16h   ; 1 qword is 8 bytes and 1 byte stores 2 digits ie u have to print 16 digits present in 1 qword & this count 16 is stored in cl
	mov rsi , loc    
up:	rol rbx , 04h  ;1st digit in rbx will keep on printing to console cuz after 4 rotations 1st nibble becomes last nibble 
	mov al , bl
	AND al , 0Fh
	CMP al , 09h
	JBE next
	ADD al ,07h
next:	ADD al , 30h
	mov byte[rsi] , al   ;rsi is pointing to loc rn so move the hex value converted to ascii (to be printed final value) to loc
	INC rsi
	DEC cl
	JNZ up
	RET

section .data
	array dq 1122334455667788h, 2233445566778899h, 3344556677889900h, 4455667788990011h, 5566778899001122h , 0h ,0h , 0h , 0h , 0h  
                     ;0h is so that msgs do not get stored immediately after array1 digits and we have space for non-overlapping blk transfer 
	array2 dq 0h ,0h , 0h , 0h , 0h
	msg1: db "Original data is", 10
	len1: equ $-msg1               ; in memory msgs get stored immediately after array contents
	msg2: db "Final data is", 10
	len2: equ $-msg2
	msg3: db " : "
	len3: equ $-msg3
	msg4: db 10
	len4: equ $-msg4
	msg5: db "1-> Non overlapping Block Transfer without string", 10
	len5: equ $-msg5
	msg6: db "2-> Non overlapping Block Transfer with String", 10
	len6: equ $-msg6
	msg7: db "3-> Overlapping Block Transfer without string", 10
	len7: equ $-msg7
	msg8: db "4-> Overlapping Block Transfer with String", 10
	len8: equ $-msg8
	msg9: db "Enter choice : ", 10
	len9: equ $-msg9
	msg10: db "5-> EXIT", 10
	len10: equ $-msg10

section .bss
	count resb 2
	loc resb 16   ; loc is given 16 bytes so that each byte(memory organisation) stores 1 digit finally converted to desired form (eg H to ASCII) 
                      ; and digits in each num of array moved to loc is 16 	
	choice resb 2
	
section .text
_start:
	Print 1, 1, msg1 , len1
	PrintBlock array, up1    ;we need to pass a label into macro cuz if label(not a parameter) given in macro that label gets created  
	                         ; multiple times in memory and confuses compiler
menu:	Print 1, 1, msg5 , len5
	Print 1, 1, msg6 , len6
	Print 1, 1,msg7 , len7
	Print 1, 1,msg8 , len8
	Print 1, 1,msg10 , len10
 	Print 1, 1,msg9 , len9
	Print 0,0, choice, 2 
	
	mov al, [choice]
	sub al, 30h
	CMP al, 01h
	JE case1
	CMP al, 02h
	JE case2
	CMP al, 03h
	JE case3
	CMP al, 04h
	JE case4
	JMP case5
	
	
case1:	;Non-Overlapping Simple Transfer
	mov rsi , array
	mov rdi , array+40
	mov byte[count] , 5h
label:	mov rbx , qword[rsi]
	mov qword[rdi] , rbx
	ADD rsi , 8   ;being a qword 
	ADD rdi , 8
	DEC byte[count]
	JNZ label
	Print 1,1,msg2, len2
	PrintBlock array+40, up2  
	JMP menu
	
case2:	;Non-Overlapping String Transfer
	mov rsi , array
	mov rdi , array+40  ; immediately after source blk dest blk starts 
	mov byte[count] , 5h	
label1:	CLD	
	movsq			;decrements or increments si and di automatically ;here source and direction not mentioned??-> its rsi to rdi
	DEC byte[count]
	JNZ label1
	Print 1,1,msg2, len2
	PrintBlock array+40, up3
	JMP menu
	
case3: ;Overlapping Simple Transfer
	mov rsi , array
	mov rdi , array2	;first 40(5x4x2 bytes) locations occupied by input data, next 40 by 0h next by 					;messages and then, is the temporary location. that is why, rdi<-array+120
	mov byte[count] , 5h
label2:	mov rbx , qword[rsi]
	mov qword[rdi] , rbx
	ADD rsi , 8  ; each array data is a qword i.e 8 bytes
	ADD rdi , 8
	DEC byte[count]
	JNZ label2
	
	mov rsi , array2
	mov rdi , array+16
	mov byte[count] , 5h
label3:	mov rbx , qword[rsi]
	mov qword[rdi] , rbx
	ADD rsi , 8
	ADD rdi , 8
	DEC byte[count]
	JNZ label3
	Print 1,1,msg2, len2
	PrintBlock array+16, up4
	JMP menu
	
case4: ;Overlapping String Transfer
	mov rsi , array
	mov rdi , array2
	mov byte[count] , 5h	
label4:	CLD
	movsq
	DEC byte[count]
	JNZ label4
	
	mov rsi , array2
	mov rdi , array+16
	mov byte[count] , 5h	
label5:	CLD
	movsq
	DEC byte[count]
	JNZ label5
	Print 1,1,msg2, len2
	PrintBlock array+16, up5
	JMP menu
	
case5: 	mov rax, 60
	mov rdi, 0
	syscall
