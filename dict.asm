extern string_equals

global find_word

section .text

; Принимает казатель на нуль-терминированную строку (rdi) и указатель на начало словаря (rsi)
; Проходит по всему словарю в поисках подходящего ключа.
; Если подходящее вхождение найдено, вернёт адрес начала вхождения в словарь, иначе вернёт 0. 
find_word:
    test rsi, rsi
    jz .key_not_found 
    push rdi
    push rsi
    add rsi, 8
    call string_equals
    pop rsi
    pop rdi
    test rax, rax
    jnz .key_found
    mov rsi, [rsi]
    jmp find_word
.key_found:
    mov rax, rsi
    ret
.key_not_found:
    xor rax, rax
    ret