global bootloader
section .boot

bits 32
bootloader:
	mov eax, 0x0e41
	int 0x10
	hlt
boot_end:

times (510 - (boot_end - bootloader)) db 0
dw 0xaa55
