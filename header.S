	.code16
	.section ".header", "ax"
	.global boot_start

boot_start:
	ljmp	$0x0000, $real_start

boot_params:
	.long	0x13131313	/* magic number */
header32_size:
	.long	0x00008c00	/* kernel image size */
header32_address:
	.long	0x00100000	/* kernel load addr */
drive_number:
	.long	0x00000000	/* boot drive number */
header32_start_sector:		/*size is 70 sectors * 512*/
	.long	0x20
kernel_load_addr:
	.long 0x1000000
kernel_start_sector:
	.long	0x66
setup_sectors:
	.long	0x00000020	/* bootloader size in 512 byte blocks */

	.align 4
big_real_mode_gdt:
	.quad 0x0000000000000000
	.quad 0x00cf92000000ffff

big_real_mode_gdt_descr:
	.word (big_real_mode_gdt_descr - big_real_mode_gdt - 1)
	.long big_real_mode_gdt

real_start:
	xorl	%eax, %eax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %fs
	movw	%ax, %gs
	movw	%ax, %ss
	movl	$0x7c00,%eax
	movl	%eax, %esp

	movzbl	%dl, %eax
	movl	%eax, drive_number
	movl	setup_sectors, %eax
	dec	%al

	/*
	 * dl - drive number
	 * dh - head, set it to 0
	 */
	xorb	%dh, %dh
	/*
	 * ah - function number, 2 in this case
	 */
	movb	$0x02, %ah
	/*
	 * cl - (sector | (cylinder >> 2) & 0xC0), set it to 0
	 * ch - cylinder & 0xff, set it to 0
	 */
	movw	$0x0002, %cx
	/*
	 * bx - offset to load, all data will be loaded to es:bx, so
	 *      set it to 0x7C00 + 0x0200 = 0x7E00, right after bootsector
	 */
	movw	$0x7E00, %bx
	int	$0x13

	calll	enter_big_real_mode
	pushl	$boot_params
	calll	setup
1:
	hlt
	jmp	1b

enter_big_real_mode:
	cli
	pushw	%ds
	pushw	%es
	pushw	%gs
	pushw	%fs

	lgdt	big_real_mode_gdt_descr

	movl	%cr0, %eax
	orb	$0x01, %al
	movl	%eax, %cr0
	jmp	1f
1:
	movw	$0x08, %ax
	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %gs
	movw	%ax, %fs

	movl	%cr0, %eax
	andb	$0xFE, %al
	movl	%eax, %cr0

	popw	%fs
	popw	%gs
	popw	%es
	popw	%ds
	sti
	retl
