	.text
	.code16
	.global enter_pm
enter_pm:
	popl	%eax

	popl	%ecx
	popl	%esi

	movw 	$0x20,%di	
	movl	%cr0, %eax
	orb	$0x01, %al
	movl	%eax, %cr0
	

	
	ljmpl	$0x0010, $pm_entry

	.code32
pm_entry:
	movw	$0x0018, %ax


	movw	%ax, %ds
	movw	%ax, %es
	movw	%ax, %ss
	movw	%ax, %fs
	movw	%ax, %gs
	
	ltr %di
	xorl %edx,%edx
	xorl %ebx,%ebx
	lldt %dx
2:
	/* stub */
	jmp	*%ecx

1:
	jmp	1b
	
