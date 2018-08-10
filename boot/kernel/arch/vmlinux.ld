OUTPUT_FORMAT("elf64-x86-64","elf64-x86-64","elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
ENTRY(startup_64)

SECTIONS
{
	. = 0x100000;
	.head.text : {
		_head = .;
		*(.head.text)
		_ehead = .;
	}

	.text : {
		_text = .;
		*(.text)
		*(.text.*)
		_etext = .;
	}

	.rodata : {
		_rodata = .;
		*(.rodata)
		*(.rodata.*)
		_erodata = .;
	}

	.data : {
		_data = .;
		*(.data)
		*(.data.*)
		_edata = .;
		
	}
	. = ALIGN(64);
	.bss : {
		_bss = .;
		*(.bss)
		*(.bss.*)
		*(COMMON)
		. = ALIGN(8);
		_ebss = .;
		
	}

	. = ALIGN(4096);
	.pgtable : {
		_pgtable = .;

		*(.pgtable)
		_epgtable = .;

	}
}
