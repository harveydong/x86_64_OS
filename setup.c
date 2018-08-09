#include "boot.h"
#include "disk.h"
#include "gdt.h"
#include "console.h"
#include "pm.h"
#include "my_main.h"
#include "elf.h"
#include "types.h"

static struct boot_params params __attribute__((aligned(16)));

char *HEAP = _end;
char *heap_end = _end;

static void memcpy(void *dst,void *src,uint32 len)
{
        char *tmp_dst = (char *)dst;
        char *tmp_src = (char *)src;
        while(len--){
                (*tmp_dst) = (*tmp_src);
                tmp_dst++;
                tmp_src++;
        }
}

static void memset(void*s,int c,uint32 len)
{
        int i;
        char *ss = (char *)s;

        for(i = 0; i < len; i++)
                ss[i] = c;
}

static void load_header32(struct boot_header *header)
{
	
	/*from 32th sector to 102th is protected code. and load to memory addr is 0x100000*/
	struct disk_drive drive;
	char *load_addr = (char *)header->image_addr;
	unsigned block = header->header_start_sector;
	unsigned blocks = (header->image_size + 511) / 512;

	fill_disk_drive(header->boot_drive, &drive);
	while (blocks--) {
		read_block(&drive, block++, load_addr);
		load_addr += 512;
	}
}

static void load_kernel(struct boot_header *header)
{

	char buf[512] = {0};
	struct disk_drive drive;
	char *load_addr = (char *)header->kernel_load_addr - 512*2;
	unsigned block = header->kernel_start_sector;
	unsigned blocks = (1 + 511) / 512;
	int i,j;
	int num;

	fill_disk_drive(header->boot_drive, &drive);
	//while (blocks--) {
	read_block(&drive, block, buf);
	//load_addr += 512;
	//}


	Elf64_Ehdr *elf = (Elf64_Ehdr *)buf;
	if(elf->e_ident[0] != 0x7f || elf->e_ident[1] != 'E' || elf->e_ident[2] != 'L'|| elf->e_ident[3] != 'F'){
		puts("error read elf header\n");
		while(1);
		return;
	}

	uint32 elf_offset = 512 * header->kernel_start_sector;
	
	
	Elf64_Phdr *ph = (Elf64_Phdr*)((uint8 *)elf + elf->e_phoff);
	for(i = 0; i < elf->e_phnum; i++)
	{
		if(ph->p_type == PT_LOAD && ph->p_paddr){
			num = (ph->p_filesz + 511)/512;
			block = (elf_offset + ph->p_offset + 511) / 512;
			load_addr = (char *)ph->p_paddr;
			printf("phy load addr:0x%x,and num is:%d,filesz:0x%x\n",load_addr,num,ph->p_filesz);
			for(j = 0; j < num; j++){
				read_block(&drive, block, (load_addr));
				block++;
				load_addr += 512;
			}
		
			if(ph->p_memsz > ph->p_filesz){
				//memset((void*)(ph->p_paddr) + ph->p_offset,0,ph->p_memsz - ph->p_filesz);
				memset((void*)(load_addr),0,ph->p_memsz - ph->p_filesz);
			}
		}

		ph++;
	}
	

}
#if 0
static void init_heap(void)
{
        char *stack_end;
        if(boot_params.hdr.loadflags & CAN_USE_HEAP){
                asm("leal %P1(%%esp),%0"
                        :"=r"(stack_end):"i"(-STACK_SIZE));
                heap_end = (char *)((size_t)boot_params.hdr.heap_end_ptr+0x200);
                if(heap_end > stack_end)
                        heap_end = stack_end;
        }else{
		my_puts("WARNING:Ancient bootloader,some funcitonlity may be limited\n");

        }
}
#endif

static void set_bios_mode(void)
{
        struct biosregs ireg;
        initregs(&ireg);

        ireg.ax = 0xec00;
        ireg.bx = 2;
        intcall(0x15,&ireg,NULL);
}

static void reset_coprocessor(void)
{
	outb(0,0xf0);
	io_delay();
	outb(0,0xf1);
	io_delay();
}


static void mask_all_interrupt(void)
{
	outb(0xff,0xa1);	
	io_delay();
	outb(0xfb,0x21);
	io_delay();
}



void setup(struct boot_header *header)
{
	console_init();
	puts("Booting...");
	params.boot_header = *header;
	e820_detect(&params);
	//e820_show(&params);
	enable_a20();

	//init_heap();
	set_bios_mode();
	//set_video();
	load_header32(&params.boot_header);
	load_kernel(&params.boot_header);
	
	reset_coprocessor();
//	mask_all_interrupt(); 
//	setup_idt();
	setup_boot_gdt();

	my_main();
	enter_pm(params.boot_header.image_addr, &params);
}
