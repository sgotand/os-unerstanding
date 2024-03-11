
# boot.o: boot.s
# 	nasm -g -f elf $< -o $@  -l boot.lst

boot.img: boot.bin kernel.bin
	cat $^ > $@

boot.bin: boot.s
	nasm $< -o $@ -l boot.lst

kernel.bin: kernel.s
	nasm $< -o $@ -l kernel.lst


.PHONY: clean
clean:
	$(RM) *.img *.bin *.lst 

.PHONY: run
run: boot.img
	qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw -nographic 

.PHONY: debug
debug:
	qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw -nographic -gdb tcp::12345 -S

.PHONY: kill
kill:
	pkill qemu
