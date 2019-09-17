;Write 80387 ALP to find the roots of the quadratic equation. All ;the possible cases must be considered in calculating the roots



%macro myprintf 1		; this macro is for printing just 1 term ie for 1 %lf
	mov rdi,formatpf
	sub rsp,8
	movsd xmm0,[%1]		; xmm0 register
	mov rax,1		; rax=1 for printing 1 term
	call printf
	add rsp,8
%endmacro

%macro myscanf 1
	mov rdi,formatsf	; kind of istream to accept input 
	mov rax,0		; rax 0 for reading input
	sub rsp,8		; stack pointer kinda reservations before sp-8
	mov rsi,rsp
	call scanf		; maybe input accepted in formatsf(rdi) is copied to rsi(pointed to rsp here) so now rsp contains the input
				; hence we shld we before scanf where rsi n rdi are pointing	
	mov r8,qword[rsp]
	mov qword[%1],r8
	add rsp,8		; take sp back to top
%endmacro




section .data
	ff1: db "%lf +i %lf",10,0	; for printing 2 separate values (2 %lfs) ie a + ib 
	ff2: db "%lf -i %lf",10,0	; same here but ff2 is for a - ib
	formatpi: db "%d",10,0
	formatpf: db "%lf",10,0		; but here we r printing only 1 value
	formatsf: db "%lf",0		; it is for accepting input so no newline i.e 10
	four: dq 4
	two: dq 2
	ipart1: db " +i ",10
	ipart2: db " -i ",10


section .bss
	a: resq 1
	b: resq 1
	c: resq 1
	b2: resq 1
	fac: resq 1
	delta: resq 1
	rdelta: resq 1
	r1: resq 1
	r2: resq 1
	ta: resq 1
	realn: resq 1
	img1: resq 1
	img2: resq 1 


section .text
	extern printf		; to allow us to access gcc commands
	extern scanf
global main
main:

	;------scaning 
	myscanf a
	myscanf b
	myscanf c

	;-----printing 
	;myprintf a
	;myprintf b
	;myprintf c

	;----calculate b square
	fld qword[b]
	fmul qword[b]
	fstp qword[b2]		; pop from stack n store that value(b*b) in [b2]
	;myprintf b2

	;-----calculate 4ac
	fild qword[four]	; integer load
	fmul qword[a]
	fmul qword[c]
	fstp qword[fac]		; pop from stack n store that value in [fac]


	fld qword[b2]
	fsub qword[fac]
	fstp qword[delta]	;pop from st[0] n store to (b2 - fac)


	fild qword[two]
	fmul qword[a]
	fstp qword[ta]



	btr qword[delta],63  ;--------tests the bit, sets the carry flag if set and clears the bit too
	jc imaginary

	;--------------------real roots--------------------

	fld qword[delta]
	fsqrt
	fstp qword[rdelta]


	fldz
	fsub qword[b]
	fadd qword[rdelta]
	fdiv qword[ta]
	fstp qword[r1]
	myprintf r1

	fldz
	fsub qword[b]
	fsub qword[rdelta]
	fdiv qword[ta]
	fstp qword[r2]
	myprintf r2

	jmp exit

	;-----------------------imaginary roots------------------
	imaginary:
	fld qword[delta]
	fsqrt
	fstp qword[rdelta]

	fldz
	fsub qword[b]		; s[0] is 0 so this gives us (-b)
	fdiv qword[ta]
	fstp qword[realn]



	fld qword[rdelta]
	fdiv qword[ta]
	fstp qword[img1]


	;--------------printing img root1
	mov rdi,ff1
	sub rsp,8
	movsd xmm0,[realn]	; 1st %lf
	movsd xmm1,[img1]	; 2nd %lf
	mov rax,2		; rax=2 for printing 2 terms
	call printf
	add rsp,8
	
	;--------------printing img root2
	mov rdi,ff2
	sub rsp,8
	movsd xmm0,[realn]	; 1st %lf
	movsd xmm1,[img1]	; 2nd %lf
	mov rax,2
	call printf
	add rsp,8


exit:
	mov rax,60
	mov rdx,00

