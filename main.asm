extern _putc

;------
; ret
; "asdqwe"
; 15
;------

section .code use32
_main:
    push ebp
    mov ebp, esp

    push dword -11
    call [GetStdHandle]

    xor edx, edx
    push edx
    push edx
    push 5
    push dword [ebp + 8]
    push eax
    call [WriteConsoleA]


    xor eax, eax
    push eax
    call [ExitProcess]





; TODO:
;%x
;%d
;%o
;%b
;%%
;%s
;%c
;abi
