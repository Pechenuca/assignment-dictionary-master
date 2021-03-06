# Assignment №2:  Dictionary in assembly
---
Лабораторная работа №2: словарь на assembler

## Задание

Необходимо реализовать на ассемблере словарь в виде связного списка.
Каждое вхождение содержит адрес следующей пары в словаре, ключ и значение. 
Ключи и значения &mdash; адреса нуль-терминированых строк.

Словарь задаётся статически, каждый новый элемент добавляется в его начало. 
С помощью макросов мы автоматизируем этот процесс так, что указав с помощью новой конструкции языка новый элемент он автоматически добавится в начало списка, и указатель на начало списка обновится. Таким образом нам не нужно будет вручную поддерживать правильность связей в списке. 

Создайте макрос `colon` с двумя аргументами: ключом и меткой, которая будет сопоставлена значению.
Эта метка не может быть сгенерирована из самого значения, так как в строчке могут быть символы, которые не могут встречаться в метках, например, арифметические знаки, знаки пунктуации и т.д. После использования такого макроса можно напрямую указать значение, сопоставляемое ключу. Пример использования:

```nasm
section .data

colon "third word", third_word
db "third word explanation", 0

colon "second word", second_word
db "second word explanation", 0 

colon "first word", first_word
db "first word explanation", 0 
```


В реализации необходимо предоставить следующие файлы:

- `main.asm`
- `lib.asm`
- `dict.asm`    
- `colon.inc`

### Указания
- В файле `dict.asm` создать функцию `find_word`. Она принимает два аргумента:
  - Указатель на нуль-терминированную строку.
  - Указатель на начало словаря.

  `find_word` пройдёт по всему словарю в поисках подходящего ключа. Если подходящее вхождение найдено, вернёт адрес *начала вхождения в   словарь* (не значения), иначе вернёт 0. 

- Файл `words.inc` должен хранить слова, определённые с помощью макроса  `colon`. Включите этот файл в `main.asm`.
- В `main.asm` определите функцию `_start`, которая:
  
  - Читает строку размером не более 255 символов в буфер с `stdin`.
  - Пытается найти вхождение в словаре; если оно найдено, распечатывает в `stdout` значение по этому ключу. Иначе выдает сообщение об ошибке.

  Не забудьте, что сообщения об ошибках нужно выводить в `stderr`.

- Обязательно предоставьте `Makefile`.
