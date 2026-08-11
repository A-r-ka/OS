PREFIX = riscv64-unknown-elf-
CC = $(PREFIX)gcc
LD = $(PREFIX)ld
HARTS ?= 4

CFLAGS = -march=rv64g -mabi=lp64 -mcmodel=medany -ffreestanding -nostdlib -g

all: kernel.elf

boot.o: boot.S
	$(CC) $(CFLAGS) -c $< -o $@

kernel.elf: linker.ld boot.o
	$(LD) -T $< -o kernel.elf

run: kernel.elf
	qemu-system-riscv64 -machine virt -smp $(HARTS) -bios none -kernel kernel.elf

debug: kernel.elf
	qemu-system-riscv64 -machine virt -smp $(HARTS) -bios none -kernel kernel.elf -S -s