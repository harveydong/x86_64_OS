

all:	head32_64.bin
head_64.o:head_64.S
	gcc -mcmodel=small -c head_64.S

head32_64.bin:head_64.o
	ld -T vmlinux.ld -o head_64.elf head_64.o 
	objcopy -O binary head_64.elf head32_64.bin

clean:
	rm  *.bin *.o *.elf
