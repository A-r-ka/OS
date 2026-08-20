# LSR Register (READ)
.equ UART_LSR, 0x5
.equ UART_LSR_DATA_READY, 0x1
.equ UART_LSR_TX_READY, 0x20

# FIFO Register (WRITE)
.equ UART_FIFO, 0x2
.equ UART_FIFO_TRIGGER_LEVEL, 0x6    # location of the bits
.equ UART_FIFO_ENABLE, 0x1

.bss
    UART_BASE: .space 8


.text

# return (a0): character readed
.globl uart_pio_getc
uart_pio_getc:
    la t0, UART_BASE
    ld t0, 0(t0)
    addi t1, t0, UART_LSR
    
    1:
    lbu t2, 0(t1)
    andi t2, t2, UART_LSR_DATA_READY
    beqz t2, 1b
    
    lbu a0, 0(t0)
    ret



# a0: UART base address
# a1: FIFO enable (also size)
# Supported sizes for FIFO:    value  |  characters
#                                1    |      1
#                                2    |      4
#                                3    |      8
#                                4    |     14
.globl uart_init
uart_init:
    la t0, UART_BASE
    sd a0, 0(t0)
    beqz a1, 1f

    addi t1, a0, UART_FIFO
    srli a1, a1, UART_FIFO_TRIGGER_LEVEL
    ori a1, a1, UART_FIFO_ENABLE
    sb a1, 0(t1)

    1:
    ret

# a0: hexadecimal value to print
.globl uart_puthex
uart_puthex:
    addi sp, sp, -48
    sd ra, 40(sp)
    sd s0, 32(sp)
    sd s1, 24(sp)
    sd s2, 16(sp)
    sd s3, 8(sp)
    mv a1, a0

    addi sp, sp, -19
    mv t0, zero
    li t2, 19

    1:
    addi t0, t0, 1
    add t1, t0, sp
    sb zero, (t1)
    bne t0, t2, 1b

    li t2, 48
    sb t2, 0(sp)
    li t2, 120
    sb t2, 1(sp)

    li s0, 16
    li s1, 0xF
    li s2, 0x4
    li s3, 58

    1:
    addi t2, s0, -18
    neg t2, t2
    add t2, sp, t2
    addi s0, s0, -1
    mul t0, s0, s2
    srl t1, a1, t0
    and t1, s1, t1
    addi t1, t1, 48
    blt t1, s3, 2f
    addi t1, t1, 7
    2:
    sb t1, 0(t2)
    bnez s0, 1b

    mv a0, sp
    call uart_pio_printf

    addi sp, sp, 19

    ld s3, 8(sp)
    ld s2, 16(sp)
    ld s1, 24(sp)
    ld s0, 32(sp)
    ld ra, 40(sp)
    addi sp, sp, 48
    ret
    
# a0: decimal value to print
.globl uart_putdec
uart_putdec:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    li s1, 0
    li s0, 10
    mv s1, zero
    
    mv a1, a0
    bnez a1, 1f
    li a0, 48
    call uart_pio_putc
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret

    1:
    li t0, 0
    addi sp, sp, -1
    addi s1, s1, 1
    sb t0, 0(sp)
    2:
    div a2, a1, s0
    rem a1, a1, s0
    addi a1, a1, 48
    addi sp, sp, -1
    addi s1, s1, 1
    sb a1, 0(sp)
    mv a1, a2
    bnez a1, 2b

    mv a0, sp
    call uart_pio_printf
    add sp, sp, s1

    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret



# a0: character to send
.globl uart_pio_putc
uart_pio_putc:
    la t0, UART_BASE
    ld t0, 0(t0)
    addi t1, t0, UART_LSR

    1:
    lbu t3, 0(t1)
    andi t3, t3, UART_LSR_TX_READY
    beqz t3, 1b

    sb a0, 0(t0)

    ret

# a0: character to send
# a1: pointer to UART base address
uart_putc_address:
    li t0, UART_LSR
    add t0, a1, t0

    1:
    lbu t1, 0(t0)
    andi t1, t1, UART_LSR_TX_READY
    beqz t1, 1b

    sb a0, 0(a1)

    ret

# a0: pointer to null-terminated string
.globl uart_pio_printf
uart_pio_printf:
    addi sp, sp, -16
    sd ra, 8(sp)
    la a1, UART_BASE
    ld a1, 0(a1)

    mv a2, a0
    1:
    lbu t0, 0(a2)
    beqz t0, 1f
    mv a0, t0
    call uart_putc_address
    addi a2, a2, 1
    j 1b
    1:

    ld ra, 8(sp)
    addi sp, sp, 16
    ret

