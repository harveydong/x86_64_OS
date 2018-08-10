#include "init.h"
#include "types.h"


asmlinkage void  __init start_kernel(void)
{
	early_printk("ok I am now start kernel ....\n\n\n");
	while(1);
}
