
section .text

global _start


BUFFER_CAPACITY equ 512


;
; Description:
;	Function recreates printf behavior. 
;	Prints data in chuncks of 512 bytes.
;	Supports following specifiers:
;		%c - print out integer, represented as a char
;	!	%s - string, \0 is expected at the end of the string
;		%% - print out % sign
;  	!	%d - print out decimal     representation of an integer
;	!	%x - print out hexademical representation of an integer
;	!	%o - print out octagon     representation of an integer
;	!	%b - print out binary      representation of an integer
;
; Registers: 
;	RDI - pointer to the string to be formatted and printed
;	RSI, RDX, RCX, R8, R9 and stack - arguments
;	R10 - current position of the buffer
;	R11 - current position in the string
;	R12 - used arguments
;
_start:		push rbx
		push rsp
		push rbp
		push r12
		mov rbp, rsp
		add rbp, 0x20
;-------------------------------------------------------------------
		xor r10, r10
		xor r11, r11
		xor r12, r12

.Cmp:		cmp byte [rdi + r11], 0
		je .endProg
		call parseAndPut
		inc r11
		inc r10
		jmp .Cmp

;-------------------------------------------------------------------
; print remaining info, restore registers values and end the programm
;-------------------------------------------------------------------

.endProg:	call ReleaseBuffer

		pop r12
		pop rbp
		pop rsp
		pop rbx
		mov rax, 0x3C
		xor rdi, rdi
		syscall



;
; Description:
;	Check for % specifiers and checks buffer if it's overflowed
; Modifies:
;	rax = smth_i_dont_know_everything_Changes
;
parseAndPut:    mov al, byte [rdi + r11]
		cmp al, '%'
		je parseSpecifier

.putchar:	call putCharCheck
		ret

parseSpecifier: inc r11
		mov al, byte [rdi + r11]
		cmp al, '%'

		je putCharCheck

		cmp al, 'c'
		call nextArgument
		mov al, bl
		jmp putCharCheck
		


		

nextArgument:	cmp r12, 5
		jge .stackArgument
		cmp r12, 0
		cmove rbx, rsi
		cmp r12, 1
		cmove rbx, rdx
		cmp r12, 2
		cmove rbx, rcx
		cmp r12, 3
		cmove rbx, r8
		cmp r12, 4
		cmove rbx, r9
		jmp .endArgument
		
.stackArgument:	add r12, rbp
		mov rbx, [r12 - 5]
		sub r12, rbp
.endArgument:	inc r12
		ret


putCharCheck:	call putchar
		call checkBufferOverflow
		ret

;
; Description:
;	Puts a char from rax into Buffer[r11]
;
; Pseudo:
; 	Buffer[R10] = al
;
putchar:	mov byte [Buffer + r10], al
		ret



;
; Description:
;	checks if buffer is overflowed, prints and flushes it if so
;
; Pseudo:
;	if (r10 >= BUFFER_CAPACITY) then
;	{
;		print(BUFFER[:BUFFER_CAPACITY]);
;		flush(BUFFER); // r10 = 0
;	}
;
checkBufferOverflow:
		cmp r10, BUFFER_CAPACITY
		jge  .else
		ret
		
.else:         	push rax
		push rdi
		push rsi
		push rdx

		call ReleaseBuffer
		call Flush
		
		pop rdx
		pop rsi
		pop rdi
		pop rax

		ret

;
; Description:
;	Prints first r10 symbols of the buffer
;
; Pseudo:
;	print(Buffer[:r10]);
;

ReleaseBuffer:	mov rax, 0x1
		mov rdi, 1
		mov rsi, Buffer
		mov rdx, r10
		syscall
		ret

;
; Description:
;	Resets buffer with setting R10 back to 0
;
; Pseudo:
;	R10 = 0;
;
Flush:		mov r10, 0
		ret


section .data

String 		db "Hello %c%c%c%c%c%c%cworld%%%%", 0

section .bss

Buffer		resb BUFFER_CAPACITY
