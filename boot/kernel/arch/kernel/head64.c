#include "init.h"
#include "sections.h"
#include "string.h"
#include "p_types.h"
#include "tlbflush.h"
#include "../segment.h"
#include "desc.h"
#include "irq_fun.h"
#include "kernel.h"


static void __init clear_bss(void)
{
	memset(__bss_start,0,(unsigned long)__bss_stop - (unsigned long)__bss_start);

}

static void __init zap_identity_mappings(void)
{
	pgd_t *pgd = pgd_offset_k(0UL);
	pgd_clear(pgd);
	__flush_tlb_all();

}
void __init x86_64_start_kernel(char *real_mode_data)
{

	int i;

	
	setup_early_printk();
	clear_bss();	

	zap_identity_mappings();

//	cleanup_highmap();

	for(i = 0; i < NUM_EXCEPTION_VECTORS;i++)
	{
		set_intr_gate(i,&early_idt_handlers[i]);

	}

	early_printk("\n\n\nnihao ,I am here\n");
	while(1);
}
