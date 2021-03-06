LD ?= ld
CC ?= gcc
OBJCOPY ?= objcopy
TOPDIR ?= $(shell pwd)
CD ?= cd
CP ?= cp
CFLAGS = -Wall -g -ffreestanding -Os -march=i386 -m16
AFLAGS = -Wall -g -ffreestanding -march=i386 -m16

all: bootloader.bin

OBJS = \
	header.o \
	setup.o \
	console.o \
	utils.o \
	copy.o \
	bioscall.o \
	regs.o \
	memory.o \
	my_main.o\
	printf.o \
	a20.o \
	disk.o \
	gdt.o \
	pm.o

image: bootloader.bin
	dd if=/dev/zero of=image bs=512c count=16
	dd conv=notrunc if=bootloader.bin of=image

bootloader.bin: $(OBJS) boot.ld
	#$(LD) --oformat binary -T boot.ld $(OBJS) -o bootloader.elf
	$(LD)  -T boot.ld $(OBJS) -o bootloader.elf
	$(OBJCOPY) -O binary bootloader.elf bootloader.bin


head32_64.bin:
	$(CD) $(TOPDIR)/boot/kernel/arch/ && $(MAKE) && $(CP) head32_64.bin $(TOPDIR)/
kernel.elf:
	$(CD) $(TOPDIR)/boot/kernel/arch/kernel/ && $(MAKE) && $(CP) kernel.elf $(TOPDIR)/

install: head32_64.bin kernel.elf
	dd if=bootloader.bin of=c.img bs=512 conv=notrunc
	dd if=head32_64.bin of=c.img bs=512 seek=32 conv=notrunc
	dd if=kernel.elf of=c.img bs=512 seek=102 conv=notrunc

%.o: %.S
	$(CC) $(AFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm *.o bootloader.bin image *.elf *.bin

.PHONY: clean
