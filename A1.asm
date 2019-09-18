;Write X86/64 ALP to count number of positive and negative numbers from the array. 

section .data
        ;welmsg db 10,'Welcome to count +ve and -ve nos'
        ;welmsg_len equ $-welmsg
	
	pmsg db 'Count of +ve nos ::'
	pmsg_len equ $-pmsg

	nmsg db 10,'Count of -ve nos ::'  ;10 is for newline before nmsg
	nmsg_len equ $-nmsg

	nwline db 10

	array dw 9000h,8001h,9002h,4553h,8006h,9004h,022h
	arrcnt equ 7

	pcnt db 0
	ncnt db 0

section .bss
	dispbuff resb 2

%macro print 2
	mov rax,1
	mov rdi,1
	mov rsi,%1
	mov rdx,%2
	syscall
%endmacro

section .text
	global _start
_start:
	;print welmsg,welmsg_len

	mov rsi,array
	mov ecx,arrcnt
up1:
	bt word[rsi],15 ;These instructions first assign the value of the selected bit to CF, the carry flag
	jnc pnxt        ;CF not set i.e 15th bit is 0 i.e +ve no in rsi
	inc byte[ncnt]
	jmp pskip

pnxt:   inc byte[pcnt]
	
pskip:  add rsi,2   ;coz array contains nos of word type i.e 2 bytes 
	loop up1    ;loop instruction automatically checks content of ecx and jumps to label till [ecx]!=0

	print pmsg,pmsg_len
	mov bl,[pcnt]
	call disp8num

	print nmsg,nmsg_len
	mov bl,[ncnt]
	call disp8num

        print nwline,1
exit:
        mov rax,60
	syscall
	
disp8num:
	mov rcx,2   ; count(i.e bl i.e pcnt or ncnt) is a byte and hence contains 2 digits for printing and so rotation is needed just 2 times 
	mov rdi,dispbuff   ;dispbuff contains the count(+ve or -neg) which is internally in HEX but is stored here in ASCII format for display purpose 
	
HtA:
	;b1:	
	rol bl,4
	mov al,bl
	and al,0fh
	cmp al,09
	jbe dskip
	add al,07h
dskip:  add al,30h
	mov [rdi],al
	inc rdi
	loop HtA

	print dispbuff,2
	ret



