#include "boot.h"

struct gdt_ptr {
	unsigned short size;
	unsigned long addr;
} __attribute__((packed));


#if 0
#define GDT_ENTRY(base, limit, flags)		\
	(((limit) & 0x0000ffffull)        |	\
	(((limit) & 0x000f0000ull) << 32) |	\
	(((base)  & 0x00ffffffull) << 16) |	\
	(((base)  & 0xff000000ull) << 32) |	\
	(((flags) & 0x0000f0ffull) << 40))

static const unsigned long long boot_gdt[] __attribute__((aligned(16))) = {
	GDT_ENTRY(0, 0, 0),            /* null entry */
	GDT_ENTRY(0, 0xfffff, 0xc09a), /* code segment */
	GDT_ENTRY(0, 0xfffff, 0xc092), /* data segment */
};
#endif

#define GDT_ENTRY(flags,base,limit)	\
	((((base) & 0xff000000ULL) << (56 - 24)) |	\
	(((flags) & 0x0000f0ffULL) << 40) |		\
	(((limit) & 0x000f0000ULL) << (48 - 16)) |	\
	(((base) & 0x00ffffffULL) << 16)|		\
	(((limit) & 0x0000ffffULL)))


#define GDT_ENTRY_BOOT_CS	2
#define	__BOOT_CS	(GDT_ENTRY_BOOT_CS *8)

#define	GDT_ENTRY_BOOT_DS	(GDT_ENTRY_BOOT_CS + 1)
#define __BOOT_DS		(GDT_ENTRY_BOOT_DS * 8)

#define GDT_ENTRY_BOOT_TSS	(GDT_ENTRY_BOOT_CS + 2)
#define __BOOT_TSS		(GDT_ENTRY_BOOT_TSS * 8)

static const unsigned long long  boot_gdt[] __attribute__((aligned(16))) = {
                [GDT_ENTRY_BOOT_CS] = GDT_ENTRY(0xc09b,0,0xfffff),
                [GDT_ENTRY_BOOT_DS] = GDT_ENTRY(0xc093,0,0xfffff),
                [GDT_ENTRY_BOOT_TSS] = GDT_ENTRY(0x0089,4096,103),
};


static struct gdt_ptr ptr;

void setup_boot_gdt(void)
{
	ptr.size = sizeof(boot_gdt) - 1;
//	ptr.addr = (unsigned long)&boot_gdt + (get_ds() << 4);
	ptr.addr = (unsigned long)&boot_gdt + (get_ds() << 4);
	asm volatile("lgdtl %0" : : "m"(ptr));
}
static const struct gdt_ptr null_idt = {0,0};

void setup_idt(void)
{
	
	asm volatile("lidtl %0"::"m"(null_idt));

}
