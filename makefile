PREFIX = riscv64-unknown-elf-
CC = $(PREFIX)gcc
LD = $(PREFIX)ld
HARTS ?= 4
ASMS := $(wildcard *.s) $(wildcard drivers/*.s)
OBJ := $(patsubst %.s, ./obj_compiled/%.o, $(notdir $(ASMS)))

CFLAGS = -march=rv64g -mabi=lp64 -mcmodel=medany -ffreestanding -nostdlib -g

SRC_DIRS := $(sort $(dir $(ASMS)))
vpath %.s $(SRC_DIRS)


all: kernel.elf

./obj_compiled/%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

kernel.elf: linker.ld $(OBJ)
	$(LD) -T linker.ld $(OBJ) -o kernel.elf

run: kernel.elf
	qemu-system-riscv64 -machine virt -smp $(HARTS) -bios none -kernel kernel.elf

run_nographic: kernel.elf
	qemu-system-riscv64 -machine virt -smp $(HARTS) -bios none -kernel kernel.elf -nographic

debug: kernel.elf
	qemu-system-riscv64 -machine virt -smp $(HARTS) -bios none -kernel kernel.elf -S -s

.PHONY: clean
clean:
	find . -type f -name "*.o" -delete
	rm -f kernel.elf