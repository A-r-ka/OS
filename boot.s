.data
    UART: .dword 0x10000000
    SIFIVE_TEST_BASE: .dword 0x100000
    POWER_OFF: .dword 0x5555
    hello: .string "Hello, World! EITA PEGAAAAAA\n"

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

    la a0, UART
    ld a0, 0(a0)
    call uart_init

    la a0, hello
    call uart_printf

power_off:
    la t0, SIFIVE_TEST_BASE
    ld t0, 0(t0)
    la t1, POWER_OFF
    ld t1, 0(t1)
    sw t1, 0(t0)

pause_hart:
    wfi
    j pause_hart
