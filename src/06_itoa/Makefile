
# boot.o: boot.s
# 	nasm -g -f elf $< -o $@  -l boot.lst
boot.img: boot.s# boot.o
	nasm -g $< -o $@ -l boot.lst


.PHONY: clean
clean:
	$(RM) boot.img boot.lst

.PHONY: run
run:
	qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw -nographic 

.PHONY: debug
debug:
	qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw -nographic -gdb tcp::12345 -S

.PHONY: kill
kill:
	pkill qemu
