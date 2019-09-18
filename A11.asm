;Write 80387 ALP to obtain: i) Mean ii) Variance iii) Standard Deviation Also plot the
;histogram for the data set. The data elements are available in a text file.


%macro Print 04
	mov rax , %1
	mov rdi , %2
	mov rsi , %3
	mov rdx , %4
	syscall
%endmacro

print_fun: 		FIMUL word[hun]          ;Multiply ST[0] by hun and store result in ST[0].
			FBSTP [buff]             ;Converts the value in the ST[0] to an 18-digit packed BCD integer by 0 padding, stores the result in the 						 ;destination operand, and POPS THE REGISTER STACK also 2 digits for sign so intotal 20 digits
			mov rsi , buff+9	 ; same as gdtr pointing logic
			mov byte[cnt] , 09h	 ; cuz 9 times we wanna print 2 digits ie 9 times call up2 procedure

up2:			mov bl , byte[rsi]	 ; 2 digits moved to bl 
			PUSH rsi
	
			CALL HtoA
			Print 1 , 1 , result , 2
			POP rsi
			DEC rsi
			DEC byte[cnt]
			JNZ up2
	
			Print 1 , 1 , dot ,lend
	
			mov bl , byte[buff]
			CALL HtoA
			Print 1 , 1 , result , 2
			RET

HtoA: 		mov ax, 00h
		mov byte[count] , 02h
		mov rsi , result
p1:		rol bl , 04h
		mov al , bl
		AND al , 0Fh
		CMP al , 09h
		JBE p2
		ADD al ,07h
p2:		ADD al , 30h
		mov byte[rsi] , al
		INC rsi
	 	DEC byte[count]
		JNZ p1	
		RET


section .data
	msg_m: db "The mean of Numbers is "
	len_m: equ $-msg_m
	
	msg_v: db "The variance of Numbers is "
	len_v: equ $-msg_v
	
	dot: db "."
	lend: equ $-dot

	new: db 10
	
	msg_sd: db "The Standard Deviation of Numbers is "
	len_sd: equ $-msg_sd
	
	array dd 10.21 , 20.31 , 30.42 , 40.54 , 50.63		; dd-> 4 bytes
	count db 00
	hun dw 100
	cnt dw 5

section .bss
	mean resb 10
	variance resb 10
	sd resb 10
	buff resb 10
	result resb 16

 
section .txt
global _start
_start:

		FINIT			; to initialise math coprocessor
		mov rsi , array
		mov byte[cnt] , 05h

		FLDZ                	;load entire stack with 0.0
l1:		FADD dword[rsi]     	;add contents of rsi with ST[0] and store result in ST[0]
		ADD rsi , 4
		DEC byte[cnt]
		JNZ l1
		
		mov byte[cnt] , 05h
		FIDIV word[cnt]   	;Divide ST[0] by count and store result in ST[0].
		FST dword[mean]		; store from st[0] to [mean]
		
		Print 1 , 1 , msg_m , len_m
		CALL print_fun
		
		mov rsi , array
		mov byte[cnt] , 05h
		FLDZ				; initialise entire entire stack to 0.0
		
l2:		FLD dword[rsi]			; load to st[0] from [rsi]
		FSUB dword[mean]
		FMUL ST0			; square st[0] 		
		
		FADD  		        	; add ST[0] and ST[1] and stores result in ST[0]         		
	
		FST ST1				; Store(copy) from ST[0] to ST[1]
	
		ADD rsi , 4
		DEC byte[cnt]
		JNZ l2
	
		mov byte[cnt] , 05h	
		FIDIV word[cnt]
	
		FST dword[variance]

		Print 1 , 1 , new , 1
		Print 1 , 1 , msg_v , len_v   
	
		CALL print_fun
		

l3:		FLDZ
		FLD dword[variance]	; to(load) s[0] from [variance]
		FSQRT 
		FST dword[sd]		; from(store) st[0] to [sd]
	
		Print 1 , 1 , new , 1
		Print 1 , 1 , msg_sd , len_sd
	
		CALL print_fun
		Print 1 , 1 , new , 1
		
exit: 		mov rax , 60
		mov rdi , 0
		syscall

		
