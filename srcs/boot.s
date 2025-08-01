# boot.s - Boot 64-bit avec Multiboot2
.set MULTIBOOT2_MAGIC,              0xe85250d6
.set MULTIBOOT2_ARCHITECTURE_I386,  0
.set MULTIBOOT2_HEADER_LENGTH,      (multiboot2_header_end - multiboot2_header_start)
.set MULTIBOOT2_CHECKSUM,           -(MULTIBOOT2_MAGIC + MULTIBOOT2_ARCHITECTURE_I386 + MULTIBOOT2_HEADER_LENGTH)

.section .multiboot2
.align 8
multiboot2_header_start:
    .long MULTIBOOT2_MAGIC
    .long MULTIBOOT2_ARCHITECTURE_I386
    .long MULTIBOOT2_HEADER_LENGTH
    .long MULTIBOOT2_CHECKSUM
    
    # End tag
    .word 0    # type
    .word 0    # flags
    .long 8    # size
multiboot2_header_end:

.section .bss
.align 16
stack_bottom:
.skip 16384  # 16 KiB stack
stack_top:

.section .text
.global _start
.type _start, @function
_start:
    # On démarre en mode 32-bit, il faut passer en 64-bit
    
    # Désactiver les interruptions
    cli
    
    # Configurer la pile temporaire
    mov $stack_top, %esp
    
    # Sauvegarder les informations multiboot
    mov %eax, %edi  # Magic number
    mov %ebx, %esi  # Multiboot info structure
    
    # Vérifier le support 64-bit
    call check_multiboot
    call check_cpuid
    call check_long_mode
    
    # Configurer la pagination pour le mode long
    call setup_page_tables
    call enable_paging
    
    # Charger la GDT 64-bit
    lgdt [gdt64.pointer]
    
    # Saut vers le mode long
    jmp gdt64.code:long_mode_start

check_multiboot:
    cmp $0x36d76289, %eax
    jne .no_multiboot
    ret
.no_multiboot:
    mov $'0', %al
    jmp error

check_cpuid:
    # Vérifier si CPUID est supporté
    pushf
    pushf
    xor $0x00200000, (%esp)
    popf
    pushf
    pop %eax
    xor (%esp), %eax
    popf
    and $0x00200000, %eax
    jz .no_cpuid
    ret
.no_cpuid:
    mov $'1', %al
    jmp error

check_long_mode:
    # Vérifier le support du mode long via CPUID
    mov $0x80000000, %eax
    cpuid
    cmp $0x80000001, %eax
    jb .no_long_mode
    
    mov $0x80000001, %eax
    cpuid
    test $(1 << 29), %edx
    jz .no_long_mode
    ret
.no_long_mode:
    mov $'2', %al
    jmp error

setup_page_tables:
    # Nettoyer les tables de pages
    mov $p4_table, %edi
    mov %edi, %cr3
    xor %eax, %eax
    mov $4096, %ecx
    rep stosl
    mov %cr3, %edi
    
    # Configurer P4 -> P3
    mov $p3_table, %eax
    or $0b11, %eax  # Present + writable
    mov %eax, (%edi)
    
    # Configurer P3 -> P2
    mov $p2_table, %eax
    or $0b11, %eax
    mov %eax, p3_table
    
    # Configurer P2 (identity mapping pour les premiers 2MB)
    mov $0b10000011, %eax  # Present + writable + huge
    mov %eax, p2_table
    
    ret

enable_paging:
    # Activer PAE
    mov %cr4, %eax
    or $(1 << 5), %eax
    mov %eax, %cr4
    
    # Activer le mode long
    mov $0xC0000080, %ecx
    rdmsr
    or $(1 << 8), %eax
    wrmsr
    
    # Activer la pagination
    mov %cr0, %eax
    or $(1 << 31), %eax
    mov %eax, %cr0
    
    ret

error:
    mov $0x4f524f45, 0xb8000  # "ER" en rouge
    mov $0x4f524f52, 0xb8004  # "RO" en rouge
    mov %al, 0xb8008
    hlt

.code64
long_mode_start:
    # Nettoyer les registres de segment
    mov $gdt64.data, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss
    
    # Configurer la pile 64-bit
    mov $stack_top, %rsp
    
    # Appeler le kernel principal
    call kernel_main
    
    # Boucle infinie
    cli
1:  hlt
    jmp 1b

# GDT 64-bit
.section .rodata
gdt64:
    .quad 0  # Null descriptor
.code: equ $ - gdt64
    .quad (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53)  # Code segment
.data: equ $ - gdt64
    .quad (1<<44) | (1<<47) | (1<<41)  # Data segment
.pointer:
    .word $ - gdt64 - 1
    .quad gdt64

# Tables de pages
.section .bss
.align 4096
p4_table:
    .skip 4096
p3_table:
    .skip 4096
p2_table:
    .skip 4096