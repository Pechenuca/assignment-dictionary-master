global exit
global string_length
global print_string
global print_char
global print_newline
global print_uint
global string_equals
global parse_uint
global parse_int
global string_copy
global read_char
global read_word
section .text

; Принимает код возврата и завершает текущий процесс
exit:
	mov rax, 60
	syscall
	ret

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    mov rax, 0
.loop:
    cmp byte[rdi + rax], 0
    je .end
    inc rax
    jmp .loop
.end:
    ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
	push rdi
	call string_length
	pop rsi
	mov rdx, rax
	mov rdi, 1
	mov rax, 1
	syscall
	ret

; Принимает код символа и выводит его в stdout
print_char:
	push rdi
	mov rdi, rsp
	call print_string
	pop rdi
	ret

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
	mov rdi, 0xA
	call print_char
	ret

; Выводит беззнаковое 8-байтовое число в десятичном формате
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
print_uint:
    mov r10, 10
    mov rax, rdi
    mov rdi, rsp
    dec rdi
    push 0
    sub rsp, 16
.loop:
    xor rdx, rdx
    div r10
    add rdx, '0'
    dec rdi
    mov [rdi], dl
    cmp rax, 0
    jne .loop
.end:
    call print_string
    add rsp, 24
    ret

; Выводит знаковое 8-байтовое число в десятичном формате
print_int:
	cmp rdi, 0
	jnl positive
	negative:
	push rdi
	mov rdi, '-'
	call print_char
	pop rdi
	neg rdi
	positive:
	call print_uint
	ret

; Принимает два указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals: ;rdi rsi
	xor rcx, rcx
	.loop:
	xor r9, r9
	xor r10, r10
	mov r9b, byte[rdi+rcx]
	mov r10b, byte[rsi+rcx]
	cmp r9, r10
	je .next_char
	jmp .end_bad


.next_char:
	cmp byte[rdi+rcx], 0
	je .end_good
	inc rcx
	jmp .loop


.end_good:
	xor rax, rax
	mov rax, 1
	ret
.end_bad:
	xor rax, rax
	ret

; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
	xor rdi, rdi
	xor rax, rax
	mov rdx, 1
	push qword 0
	mov rsi, rsp
	syscall
	pop rax
	ret

; Принимает: адрес начала буфера, размер буфера
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор

read_word: ;rdi-adress; rsi-length of buf
	xor r9, r9 ; r9 - count of chars
	mov r10, rdi ; r10 - adress
.loop:
	push rdi
	push rsi
	call read_char
	pop rsi
	pop rdi
	cmp r9, 0
	jz .space
.next:
	cmp r9, rsi
	jae .error
	cmp rax, 0
	jz .end
	mov [rdi + r9], rax

	cmp rax, 0x20
	jz .end
	cmp rax, 0x9
	jz .end
	cmp rax, 0xa
	jz .end

	inc r9
	jmp .loop

.space:
	cmp rax, 0x20
	jz .loop
	cmp rax, 0x9
	jz .loop
	cmp rax, 0xa
	jz .loop
	jmp .next

.error:
	xor rax, rax
	ret
.end:
	xor rax, rax
	mov [rdi + r9], rax
	mov rax, r10
	mov rdx, r9
	ret


; Принимает указатель на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint: ;rdi - adress of word
	xor r9, r9; for i
	mov r10, 10 ; mul
	xor rax, rax
	xor r8, r8 ; char
.loop:
	mov r8b, byte[rdi + r9]
	cmp r8b, '0'
	jb .end
	cmp r8b, '9'
	ja .end

	sub r8b, '0'
	xor rdx, rdx
	mul r10
	add rax, r8
	inc r9
	jmp .loop



.end:
	mov rdx, r9
	ret

; Принимает указатель на строку, пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был)
; rdx = 0 если число прочитать не удалось
parse_int: ; rdi - adress
	xor r8, r8 ; for i
	xor r9, r9 ; char
	mov r10, 10 ; mul
	push 0 ; is positive
	xor rax, rax

first_char:
	xor r9, r9
	mov r9b, byte[rdi]
	cmp r9b, '-'
	je .minus
	cmp r9b, '0'
	jb .end
	cmp r9b, '9'
	ja .end
	sub r9b, '0'
	xor rdx, rdx
	mul r10
	add rax, r9
	inc r8
.loop:
	xor r9, r9
	mov r9b, byte[rdi + r8]
	cmp r9b, '0'
	jb .end
	cmp r9b, '9'
	ja .end
	sub r9b, '0'
	xor rdx, rdx
	mul r10
	add rax, r9
	inc r8
	jmp .loop


.minus:
	mov rcx, 1
	mov [rsp], rcx
	inc r8
	jmp .loop

.makeneg:
	neg rax
	mov rdx, r8
	ret

.end:
	pop r9
	cmp r9, 1
	jz .makeneg
	mov rdx, r8
	ret

; Принимает указатель на строку, указатель на буфер и длину буфера
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy: ;rdi-string adr rsi-buffer addr rdx-buffer length
	xor r9, r9
.loop:	cmp rdx, 0
	je .error
	xor r8, r8
	mov r8b, byte[rdi]
	mov byte[rsi], r8b
	inc r9
	inc rsi
	inc rdi
	dec rdx
	cmp r8, 0
	jne string_copy
	mov rax, r9
	ret
.error:
	xor rax, rax
	ret