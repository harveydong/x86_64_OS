#include "required-features.h"
verify_cpu:
	pushfl
	pushl $0
	popfl
	
	pushfl
	popl %eax
	movl %eax,%bx
	xorl $0x200000,%eax
	pushl %eax
	popl
	pushfl
	cmpl %eax,%ebx
	jz verify_cpu_no_longmode
	
	movl $0x0,%eax
	cpuid
	cmpl $0x1,%eax
	jb verify_cpu_no_longmode
	
	xor %di,%di
	cmpl $0x68747541,%ebx
	jnz verify_cpu_noamd
	cmpl $0x69746e65,%edx
	jnz verify_cpu_noamd
	cmpl $0x444d4163,%ecx
	jnz verify_cpu_noamd
	movl $1,%di
	
verify_cpu_noamd:
	movl $0x1,%eax
	cpuid
	andl $REQUIRED_MASK0,%edx
	xorl $REQUIRED_MASK0,%edx
	jnz verify_cpu_no_longmode
		
	movl $0x80000000,%eax
	cpuid
	cmpl $0x80000001,%eax
	jb verify_cpu_no_longmode
	
	movl $0x80000001,%eax
	cpuid
	andl $REQUIRED_MASK1,%edx
	xorl $REQUIRED_MASK1,%edx
	jnz verify_cpu_no_longmode
	
verify_cpu_sse_test:
	movl $1,%eax
	cpuid
	andl $SSE_MASK,%edx
	cmpl $SSE_MASK,%edx
	je verify_cpu_sse_ok
	test %di,%di
	jz verify_cpu_no_longmode
	movl $0xc0010015,%ecx
	rdmsr
	btr $15,%eax
	wrmsr
	xor %di,%di
	jmp verify_cpu_sse_test
	
verify_cpu_no_longmode:
	popfl
	movl $1,%eax
	ret
verify_cpu_sse_ok
	popfl
	xorl %eax,%eax
	ret
