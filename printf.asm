global main


section .text


BUFFER_CAPACITY equ 512


;
; Description:
;	Function recreates printf behavior. 
;	Prints data in chuncks of 512 bytes.
;	Supports following specifiers:
;		%c - print out integer, represented as a char
;		%s - string, \0 is expected at the end of the string
;		%% - print out % sign
;  		%d - print out decimal     representation of an integer
;		%x - print out hexademical representation of an integer
;		%o - print out octagon     representation of an integer
;		%b - print out binary      representation of an integer
;
; Registers: 
;	RDI - pointer to the string to be formatted and printed
;	RSI, RDX, RCX, R8, R9 and stack - arguments
;	R10 - current position of the buffer
;	R11 - current position in the string
;
;
main:
		push rbx ; save registers for the calling convention 
		push rsp
		push rbp
		push r10 
		push r11
;-------------------------------------------------------------------
				




;-------------------------------------------------------------------
; restore registers values as the convention says
;-------------------------------------------------------------------
		pop r11
		pop r10
		pop rsp
		pop rbx ; restore rbx value
		ret



;
; Description:
;	Acts the same as putchar, but checks buffer if it's overflowed
;
putCharCheck:
		call putchar
		call checkBufferOverflow
		ret
		


;
; Description:
;	Puts a byte in string[r10] into Buffer[r11]
;
; Pseudo:
; 	Buffer[R10] = String[R11]
;
putchar:
		push rbx
		mov bl, byte[rdi, r11]
		mov byte [Buffer + r10], bl
		pop rbx
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

ReleaseBuffer:
		mov rax, 0x1
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
Flush:
		mov r10, 0
		ret


section .bss

Buffer		resb BUFFER_CAPACITY
