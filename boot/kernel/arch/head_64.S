#include "linkage.h"
#include "boot.h"
#include "segment.h"
#include "cpufeature.h"
#include "../../processor-flags.h"

	.code32
	.text
	
	.section ".head.text","ax"
	.code32
	
	.globl startup_32
	ALIGN
startup_32:
	cld
//	testb $(1<<6),BP_loadflags(%esi)
//	jnz 1f
	cli

	movl $(__KERNEL_DS),%eax
	movl %eax,%ds
	movl %eax,%es
	movl %eax,%ss

	//leal (BP_scratch + 4)(%esi),%esp
	call 1f
1:
	popl %ebp
	subl $1b,%ebp
	
	movl $boot_stack_end,%eax
	addl %ebp,%eax
	movl %eax,%esp

	#call verify_cpu
#	testl %eax,%eax
#	jnz no_longmode


	movl $LOAD_PHYSICAL_ADDR,%ebx
	leal gdt(%ebp),%eax
	movl %eax,gdt+2(%ebp)
	lgdt gdt(%ebp)

	movl $(X86_CR4_PAE),%eax
	movl %eax,%cr4
	
	leal pgtable(%ebp),%edi
	xorl %eax,%eax
	movl $((6*4096/4)),%ecx
	rep stosl


	/*level 4 page table*/
	leal pgtable+0(%ebp),%edi
	leal 0x1007(%edi),%eax
	movl %eax,0(%edi)

	/*level 3 page table*/
	leal pgtable + 0x1000(%ebp),%edi
	leal 0x1007(%edi),%eax
	movl $4,%ecx

1:	movl %eax,0x00(%edi)
	addl $0x00001000,%eax
	addl $8,%edi
	decl %ecx
	jnz 1b	

	/*build level 2*/
	leal pgtable + 0x2000(%ebp),%edi
	movl $0x00000183,%eax
	movl $2048,%ecx
1:
	movl %eax,0(%edi)
	addl $0x00200000,%eax
	addl $8,%edi
	decl %ecx
	jnz 1b


	leal pgtable(%ebp),%eax
	movl %eax,%cr3

	movl $MSR_EFER,%ecx
	rdmsr
	btsl $_EFER_LME,%eax
	wrmsr

	pushl $__KERNEL_CS
	leal startup_64(%ebp),%eax
	pushl %eax

	xorl %eax,%eax

	movl %cr0,%eax
	btsl $31,%eax
2:
	movl %eax,%cr0

	lret

	.type startup_32,@function
	.size startup_32,.-startup_32

	.code64
	.org 0x200
	.globl startup_64
startup_64:
	xorl %eax,%eax
	movl %eax,%ds
	movl %eax,%es
	movl %eax,%ss
	movl %eax,%fs
	movl %eax,%gs
	
	lldt %ax
	
	movl $0x20,%eax
	ltr %ax
	
	movq $LOAD_PHYSICAL_ADDR,%rbx
	

	leaq boot_stack_end(%rbx),%rsp
	
	pushq $0
	popfq
	
	pushq %rsi
	leaq (_bss - 8)(%rip),%rsi
	leaq (_bss - 8)(%rbp),%rdi
	movq $_bss,%rcx
	shrq $3,%rcx
	std

	rep movsq
	cld
	popq %rsi
	
	leaq relocated(%rbp),%rax
	jmp *%rax

	.text
relocated:
	xorl %eax,%eax
	leaq _bss(%rip),%rdi
	leaq _ebss(%rip),%rcx
	subq %rdi,%rcx
	shrq $3,%rcx
	
	rep stosq
	pushq %rsi
	movq %rsi,%rdi
	leaq boot_heap(%rip),%rsi

	
	popq %rsi
	movq %rbx,%rbp
	jmp *%rbp
	
	.data
gdt:
	.word gdt_end - gdt
	.long gdt
	.word 0
	.quad 0x0000000000000000
//	.quad 0x00af9a000000ffff
//	.quad 0x00cf92000000ffff
	.quad 0x0020980000000000
	.quad 0x0000920000000001
	.quad 0x0080890000000000
	.quad 0x0000000000000000
gdt_end:


	.bss
	.balign 4
boot_heap:
	.fill BOOT_HEAP_SIZE,1,0
boot_stack:
	.fill BOOT_STACK_SIZE,1,0
boot_stack_end:

	.section ".pgtable","a",@nobits
	.balign 4096
pgtable:
	.fill 6*4096,1,0	
