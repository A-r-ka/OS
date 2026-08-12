.data
    UART_LSR: .dword 0x5
    UART_LSR_TX_READY: .dword 0x20


.bss
    UART_BASE: .space 8

.text

# a0: UART base address
.globl uart_init
uart_init:
    la t0, UART_BASE
    sd a0, 0(t0)
    ret


# a0: character to send
.globl uart_putc
uart_putc:
    la t0, UART_BASE
    ld t0, 0(t0)
    la t1, UART_LSR
    ld t1, 0(t1)
    la t2, UART_LSR_TX_READY
    ld t2, 0(t2)
    add t1, t0, t1

    1:
    lbu t3, 0(t1)
    and t3, t2, t3
    beqz t3, 1b
    sb a0, 0(t0)

    ret

# a0: pointer to null-terminated string
.globl uart_printf
uart_printf:
    addi sp, sp, -16
    sd ra, 8(sp)

    mv a1, a0
    1:
    lbu t0, 0(a1)
    beqz t0, 1f
    mv a0, t0
    call uart_putc
    addi a1, a1, 1
    j 1b
    1:

    ld ra, 8(sp)
    addi sp, sp, 16
    ret

