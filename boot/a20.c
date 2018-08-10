#include "header_32.h"

static int a20_test(int loops)
{
	int ok = 0;
	int saved,ctr;
	
	set_fs(0x0000);
	set_gs(0xffff);

	saved = ctr =rdfs32(4*0x80);
	
	while(loops--){
		wrfs32(++ctr,4*0x80);
		io_delay();
		ok = rdgs32(4*0x80+0x10) ^ ctr;

		if(ok)
			break;

	}

	wrfs32(saved,4*0x80);

	return ok;

}


static int a20_test_short(void)
{
	a20_test(32);
}

int enable_a20(void)
{
	int loops = 255;
	int kbc_err;

	while(loops--){
		if(a20_test_short())
			return 0;
	
		
	}

	return 0;
}
