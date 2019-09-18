;Write a TSR to generate the pattern of the frequency tones by reading the Real Time
;Clock (RTC). The duration of the each tone is solely decided by the programmer.

.MODEL TINY 	; CS and DS point to same memory location
.286		; equivalence of _start
ORG 100H	; ??


CODE SEGMENT
     ASSUME CS:CODE,DS:CODE,ES:CODE	;??
        OLD_IP DW 00
        OLD_CS DW 00
JMP INIT

MY_TSR:
        PUSH AX	
        PUSH BX
        PUSH CX
        PUSH DX				; es-> cs(base) and bx->ip(offset)
        PUSH SI
        PUSH DI
        PUSH ES

        MOV AX,0B800H			;Address of Video RAM
        MOV ES,AX			; base address in es so here we use es:di combination to locate clock on screen
        MOV DI,3650			; change values to move clock position

        MOV AH,02H			;To Get System Clock
        INT 1AH				;CH=Hrs, CL=Mins,DH=Sec 					
        MOV BX,CX

        MOV CL,2			; this is done before every loop and cl=2 cuz max no of digits for each hr,min or sec is 2 digits
LOOP1:  ROL BH,4			; hours
        MOV AL,BH
        AND AL,0FH
        ADD AL,30H
        MOV AH,17H			; background color
        MOV ES:[DI],AX			; where di-> pointing to a position on screen it's a es:di (base:offset) addressing mode
        INC DI				; cuz 2 positions r now occupied by hours
        INC DI
        DEC CL
        JNZ LOOP1

        MOV AL,':'
        MOV AH,97H			; for blinking the colon
        MOV ES:[DI],AX
        INC DI
        INC DI
	
        MOV CL,2			; 2 digits
LOOP2:  ROL BL,4			; minutes
        MOV AL,BL
        AND AL,0FH
        ADD AL,30H
        MOV AH,17H
        MOV ES:[DI],AX
        INC DI
        INC DI
        DEC CL
        JNZ LOOP2

        MOV AL,':'
        MOV AH,97H
        MOV ES:[DI],AX

        INC DI
        INC DI

        MOV CL,2			; 2 digits
        MOV BL,DH			; now seconds which was in dh		

LOOP3:  ROL BL,4
        MOV AL,BL
        AND AL,0FH
        ADD AL,30H
        MOV AH,17H
        MOV ES:[DI],AX
        INC DI
        INC DI
        DEC CL
        JNZ LOOP3

        POP ES
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX

        jmp MY_TSR

INIT:
        MOV AX,CS			;Initialize code and data
        MOV DS,AX

        CLI				;Clear Interrupt Flag  -> to disable any interrupt inbetween

        MOV AH,35H			;Get Interrupt vector Data and 	store it   ah-> function name 
        MOV AL,08H			 
        INT 21H				; same as system call

        MOV OLD_IP,BX		
        MOV OLD_CS,ES

        MOV AH,25H			;Set new Interrupt vector
        MOV AL,08H
        LEA DX,MY_TSR			; load effective address for separate My_TSR code segment we wrote
        INT 21H

        MOV AH,31H			;Make program Transient(temporary)
        MOV DX,OFFSET INIT
        STI
        INT 21H

CODE ENDS				; acts as a return

END

