.equ SIFIVE_TEST_BASE, 0x100000
.equ POWER_OFF, 0x5555
.equ UART, 0x10000000

.data
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

power_off:
    li t0, SIFIVE_TEST_BASE
    li t1, POWER_OFF
    sw t1, 0(t0)

pause_hart:
    wfi
    j pause_hart
