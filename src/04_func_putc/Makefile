
boot.img: boot.s
	nasm $< -o $@ -l boot.lst


.PHONY: clean
clean:
	$(RM) boot.img boot.lst

.PHONY: run
run:
	qemu-system-i386 -rtc base=localtime -drive file=boot.img,format=raw -nographic

.PHONY: kill
kill:
	pkill qemu
