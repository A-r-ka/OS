.data
    UART: .dword 0x10000000
    hello: .string "Hello, World!\n"

.bss
    hart0_stack: .space 4096
    hart0_stack_top:

.section .text.boot
.globl _start
_start:
    csrr a0, mhartid
    bne a0, zero, pause_hart
    la t0, _bss_start
    la t1, _bss_end

    1:
    beq t0, t1, 1f
    sd zero, 0(t0)
    addi t0, t0, 8
    j 1b 
    1:

    la sp, hart0_stack_top


    la a0, hello
    ld t1, UART

    1:
    lbu t2, 5(t1)
    andi t2, t2, 0x20
    beqz t2, 1b
    lbu t0, 0(a0)
    beqz t0, 1f
    sb t0, 0(t1)
    addi a0, a0, 1
    j 1b
    
    1: 




pause_hart:
    wfi
    j pause_hart
