%include "words.inc"

global _start

extern print_string
extern find_word
extern read_char
extern print_newline
extern string_length
extern exit

section .data

msg_input: db 'Enter a key: ', 0
msg_key_found: db 'Key found, value is: ', 0 
msg_key_not_found: db 'Key not found...', 0xA, 0
key: times 256 db 0

section .text

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер строку из stdin до тех пор, пока не встречается символ переноса строки
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину cтроки в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор
read_string:
    mov r8, rdi ; string pointer
    mov r9, rsi ; buffer length
    mov r10, 0  ; string length
.next_char:
    call read_char
    cmp rax, 0xA
    je .success
    inc r10
    cmp r10, r9
    je .error
    mov [r8+r10-1], al
    jmp .next_char
.success:
    mov byte [r8+r10], 0x0
    mov rax, r8
    mov rdx, r10
    ret
.error:
    xor rax, rax
    ret

; Принимает указатель на нуль-терминированную строку, выводит её в stderr
print_error:
    call string_length
    mov rsi, rdi    ; pointer to string
    mov rdx, rax    ; string length
    mov rax, 1      ; 'write' syscall identifier
    mov rdi, 2      ; stderr descriptor
    syscall
    xor rax, rax
    ret

_start:
    mov rdi, msg_input
    call print_string
    
    mov rdi, key
    mov rsi, 256
    call read_string

    mov rdi, key
    mov rsi, ptr_begin
    call find_word
    test rax, rax
    jz .key_not_found

    push rax
    mov rdi, msg_key_found
    call print_string
    pop rax

    mov rdi, rax
    add rdi, 8
.skip_key:
    inc rdi
    cmp byte [rdi], 0
    jne .skip_key
    inc rdi
    call print_string
    call print_newline
    call exit
.key_not_found:
    mov rdi, msg_key_not_found
    call print_error
    call exit