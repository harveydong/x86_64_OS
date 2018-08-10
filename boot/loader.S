#include "kernel.h"
.section .text
.global _start

	.code16
_start:
	jmp begin_protected_mode

begin_protected_mode:
	
 
	cli
1:
	inb $0x64,%al
	testb $0x02,%al
	jnz 1b

	movb $0xd1,%al
	outb %al,$0x64
	
2:
	inb $0x64,%al
	testb $0x2,%al
	jnz 2b
	
	movb $0xdf,%al
	outb %al,$0x60

	lgdt gdt_ptr
	movl %cr0,%eax
	orl $CR0_PE,%eax
	movl %eax,%cr0
	ljmp $SEG_KCODE << 3,$start_32


	.code32
start_32:
	movl $(SEG_KDATA<<3) ,%eax	
	movw %ax,%ds
	movw %ax,%es
	movw %ax,%fs
	movw %ax,%gs
	movw %ax,%ss
	movl $0x7c00,%esp
	call loadmain

1: 
	jmp 1b

#-----------------
#bios_read(unsigned int lba)
#-----------------
lba_sector: .word 0
saved_protect_esp: .long 0x0

.global bios_read
	
bios_read:
	pushl %ebp
	movl %esp,%ebp
	movl 8(%esp),%eax
	pusha
	pushw %ds
	pushw %es
	pushw %ss
	movl %esp,saved_protect_esp
	
	movw %ax,%si
	ljmp $(0x3<<3),$change_to_real_mode
	.code16
change_to_real_mode:
	
	mov %cr0,%eax
	btr $0,%eax
	movl %eax,%cr0
	ljmp $0,$real_mode
real_mode:
	movw %cs,%ax
	movw %ax,%ds
	movw %ax,%es
	movw %ax,%ss
	movw %ax,%gs
	movw %si,%ax
	movw $0x7500,%sp
	lidt ivt_pointer
	
	lea disk_addr,%si
	movw %ax,8(%si)
	movb $0x42,%ah
	movb $0x80,%dl
	int $0x13
	
	

change_to_protect_mode:
	lgdt gdt_ptr
        movl %cr0,%eax
        orl $CR0_PE,%eax
        movl %eax,%cr0
        jmp $SEG_KCODE << 3,$protect_mode

 
	.code32
protect_mode:
	movl saved_protect_esp,%esp
	popw %ax
	movw %ax,%ss
	popw %ax
	movw %ax,%es
	popw %ax
	movw %ax,%ds
	popa
	popl %ebp
	
	ret

disk_addr:
	.byte 0x10
	.byte 0x00
	.word 0x01
	.word 0x1000
	.word 0x1000
	.long 0x00
	.long 0x00	



	.p2align 2
gdt:
	.quad 0x0000000000000000
	.quad 0x00cf9a000000ffff
	.quad 0x00cf92000000ffff
	.quad 0x00009a000000ffff #code16 desc
	.quad 0x000092000000ffff #data16 desc

gdt_ptr:
	.word . - gdt -1
	.long gdt

ivt_pointer:
	.word 0x3ff
	.long 0


.globl change_to_real_header
change_to_real_header:

	movw %ax,%si
	ljmp $(0x3<<3),$change_to_real
	.code16
change_to_real:
	
	mov %cr0,%eax
	btr $0,%eax
	movl %eax,%cr0
	ljmp $0,$real_mode_h
real_mode_h:
	movw %cs,%ax
	movw %ax,%ds
	movw %ax,%es
	movw %ax,%ss
	movw %ax,%gs
	movw %si,%ax
	movw $0x7500,%sp
	lidt ivt_pointer
	
	movw $0x8700,%ax
	jmp *%ax

	ret


