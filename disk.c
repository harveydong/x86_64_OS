#include "boot.h"
#include "disk.h"
#include "string.h"
#include "console.h"
#include "printf.h"

struct chs_addr {
	unsigned cylinder;
	unsigned head;
	unsigned sector;
};
struct disk_addr_packet {
	unsigned char packet_size;
	unsigned char reserved;
	unsigned short count;
	unsigned short buffer_offset;
	unsigned short buffer_seg;
	unsigned long start_block;
}__attribute__((packed));


static void lba_to_chs(const struct disk_drive *info, unsigned block,
		struct chs_addr *addr)
{
	const unsigned tmp = block / info->sectors;

	addr->sector = (block % info->sectors) + 1;
	addr->head = tmp % info->heads;
	addr->cylinder = tmp / info->heads;
}

int fill_disk_drive(unsigned driveno, struct disk_drive *drive)
{
	struct biosregs iregs, oregs;

	initregs(&iregs);
	iregs.ah = 8;
	iregs.dl = driveno;
	intcall(0x13, &iregs, &oregs);

	drive->driveno = driveno;
#if 0	
	drive->heads = oregs.dh + 1;
	drive->sectors = oregs.cl & 0x3f;

	/* TODO: check for errors */
#endif

	return 0;
}

int read_block(const struct disk_drive *drive, unsigned block, void *memory)
{
	struct biosregs iregs, oregs;
	unsigned char tmp[512];

	struct disk_addr_packet buffer;

	
	//struct chs_addr chs;

	//lba_to_chs(drive, block, &chs);
	
	initregs(&iregs);
#if 0
	iregs.ah = 2;
	iregs.al = 1;
	iregs.ch = chs.cylinder & 0xFF;
	iregs.cl = chs.sector | ((chs.cylinder >> 2) & 0xC0);
	iregs.dh = chs.head;
#endif
	buffer.packet_size = 0x10;
	buffer.reserved = 0;
	buffer.count = 1;
	buffer.buffer_offset =(unsigned short)tmp;
	buffer.buffer_seg = 0;
	buffer.start_block = block;

	iregs.ah = 0x42;
	iregs.dl = drive->driveno;
	iregs.si = (unsigned long) &buffer;
#if 0
	iregs.bx = (unsigned long)buffer;
	puts("before intcall\n");
#endif

	intcall(0x13, &iregs, &oregs);
	

	
	/* TODO: check for errors */
	memcpy(memory,tmp,512);//buffer, memory, 512);
	return 0;
}
