ENTRY(bootloader)

SECTIONS
{
	. = 1M;

	.boot : {
		KEEP(*(.boot))
	}

	.text : {
		*(.text)
	}

	.data : {
		*(.data)
	}
	
	.bss : {
		*(.bss)
	}
}
