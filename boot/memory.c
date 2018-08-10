#include "header_32.h"
#include "e820.h"
#include "types.h"
#include "processor-flags.h"

#define SMAP 0x534d4150


static int detect_memory_e820(void)
{
	int count = 0;
	struct biosregs ireg,oreg;
	struct e820entry *desc = boot_params.e820_map;
	static struct e820entry buf;

	initregs(&ireg);
	ireg.ax = 0xe820;
	ireg.cx = sizeof buf;
	ireg.edx = SMAP;
	ireg.di = (size_t)&buf;
	
	do{	
		intcall(0x15,&ireg,&oreg);
		ireg.ebx = oreg.ebx;
		
		if(oreg.eflags & X86_EFLAGS_CF)	
			break;

		if(oreg.eax != SMAP){
			count = 0;
			break;
		}

		*desc++ = buf;
		count++;
	}while(ireg.ebx && count < ARRAY_SIZE(boot_params.e820_map));
}


int detect_memory(void)
{
	int err = -1;
	if(detect_memory_e820() > 0)
		err = 0;

	my_puts("detect memory done!\n");	
	return err;

}
