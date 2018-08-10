
	.code16gcc
	.text
.globl memcpy
memcpy:
	pushw %si
	pushw %di
	movw %ax,%di
	movw %dx,%si
	pushw %cx
#	movw 8(%ebp),%edi
#	movw 12(%ebp),%si
#	movw 16(%ebp),%cx
	shrw $2,%cx
	rep;movsl
	popw %cx
	
#	movw 16(%ebp),%cx
	andw $3,%cx
	rep;movsb
	popw %di
	popw %si
	ret
	.type memcpy,@function
	.size memcpy,.-memcpy


.globl memset
memset:
	pushw %di
	movw %ax,%di
	movzbl %dl,%eax
	imull $0x01010101,%eax
	pushw %cx
	shrw $2,%cx
	rep;stosl
	popw %cx
	andw $3,%cx
	rep;stosb
	popw %di
	ret
.type memset,@function
.size memset,.-memset


.globl copy_from_fs
copy_from_fs:
	pushw %ds
	pushw %fs
	popw %ds
	call memcpy
	popw %ds
	ret
.type copy_from_fs,@function
.size copy_from_fs,.-copy_from_fs

.globl copy_to_fs
copy_to_fs:
	pushw	%es
	pushw	%fs
	popw	%es
	call	memcpy
	popw	%es
	ret
.type copy_to_fs,@function
.size copy_to_fs,.-copy_to_fs

