
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
;	R12 - used arguments
;
_start:		push rbx
		push rsp
		push rbp
		push r12
		mov rsi, 251
		mov rdx, 252
		mov rcx, 253
		mov r8, 255
		mov r9, 256
		mov rbp, rsp
		mov rdi, String
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
		jne .l1
		call nextArgument
		mov al, bl
		jmp putCharCheck	; putCharCheck ends parseSpecifier
		
.l1:		cmp al, 'd'
		jne .l2
		call nextArgument
		mov rax, rbx
		jmp putDecimal		; putDecimal ends parseSpecifier
		
.l2:		cmp al, 'x'
		jne .l3
		call nextArgument
		mov rax, rbx
		mov rbx, 0x4
		jmp putInDifSys

.l3:		cmp al, 'o'
		jne .l4
		call nextArgument
		mov rax, rbx
		mov rbx, 0x3
		jmp putInDifSys

.l4:		cmp al, 'b'
		jne .l5
		call nextArgument
		mov rax, rbx
		mov rbx, 0x1
		jmp putInDifSys

.l5:		cmp al, 's'
		jne .l6
		call nextArgument
		jmp callString

.l6:
		ret	



callString: ret

		

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


putDecimal:	push rdx
		push rcx
		
		xor ecx, ecx
.l10:		mov rbx, 0xa
		cqo
		div rbx
		mov rbx, rax
		mov al, dl
		add al, '0'
		mov byte [DigitRepr + rcx], al
		inc rcx
		inc r10
		mov rax, rbx
		test rax, rax
		jnz .l10	

					; here rcx > 0
		dec rcx

		call decimalToBuf

		pop rcx
		pop rdx
		ret

;
; Description:
;	writes into the output buffer rax value in system number 2**bl
; Example:
;	// bl = 3
;	print(oct(rax))
;	// bl = 4
;	print(hex(rax))
;	// bl = 1
;	print(bin(rax))
;
putInDifSys: 	push rdx
		push rcx
		push r8
		push r9

		mov cl, bl
		mov r9b, bl

		xor r8, r8
		inc r8
		shl r8, cl
		dec r8

		xor ecx, ecx

.l3:		mov bl, al
		and bl, r8b
		call decToHex
		mov dl, al
		mov al, bl
		mov byte [DigitRepr + rcx], al
		inc rcx
		mov al, dl
		mov dl, cl
		mov cl, r9b
		shr rax, cl
		mov cl, dl
		test rax, rax
		jnz .l3

		dec rcx
		call decimalToBuf
	
		pop r9
		pop r8
		pop rcx
		pop rdx
		ret

;
; Description:
;	moves in bl hexidemical representation of bl
; Pseudo:
;	bl = hex(bl) 
;
decToHex:	cmp bl, 0xa
		jge .letterRepr
		add bl, '0'
		ret

.letterRepr:	add bl, 'a'
		sub bl, 0xa
		ret


; 
; Description:
;	Unloads DigitRepr buffer to the output buffer
; Assumes:
;	rcx - amount of digits in DigitRepr
; Modifies:
;	r10 += rcx + 1
;	rcx = -1
;
decimalToBuf:	mov al, byte [DigitRepr + rcx]
		call putCharCheck
		inc r10
		dec rcx
		test rcx, rcx 
		jns decimalToBuf
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

String 		db "Hello %o %o %o %o %xh world%%%%", 0

section .bss

Buffer		resb BUFFER_CAPACITY
DigitRepr	resb 64 
