main: main.o lib.o dict.o
	ld -o $@ $^

main.o: main.asm
	nasm -f elf64 -o $@ $<

lib.o: lib.asm
	nasm -f elf64 -o $@ $<

dict.o: dict.asm
	nasm -f elf64 -o $@ $<