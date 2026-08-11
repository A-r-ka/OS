ENTRY(_start)
INPUT(boot.o)
OUTPUT(kernel.elf)

SECTIONS {
    . = 0x80000000;
    .text : {
        *(.text.boot)
        *(.text .text.*)
    }

    . = ALIGN(4096);
    .rodata : {
        *(.rodata .rodata.*)
    }

    . = ALIGN(4096);
    .data : {
        *(.data .data.*)
    }

    . = ALIGN(4096);
    _bss_start = .;
    .bss : {
        *(.bss .bss.*)
    }
    . = ALIGN(4096);
    _bss_end = .;

    /* Free Memory (HEAP)*/
    _end = .;

}