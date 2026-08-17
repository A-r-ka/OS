# 🖥️ RISC-V OS

Um sistema operacional minimalista desenvolvido do zero em Assembly RISC-V 64-bit, rodando na plataforma virtual `virt` do QEMU.

---

## 📖 Sobre o Projeto

Este projeto é uma implementação de um sistema operacional bare-metal escrito inteiramente em Assembly RISC-V (`rv64g`). O objetivo é explorar os fundamentos de sistemas operacionais diretamente na arquitetura RISC-V, sem qualquer dependência de bibliotecas externas ou sistema operacional hospedeiro.

### ✅ O que já foi implementado

| Componente | Descrição |
|---|---|
| **Boot (`boot.s`)** | Ponto de entrada do kernel; inicializa o BSS, configura a stack do hart 0 e para os demais harts em `wfi` |
| **Driver UART (`drivers/uart.s`)** | Driver para a UART NS16550A emulada pelo QEMU; suporta `uart_init`, `uart_putc` e `uart_printf` |
| **Linker Script (`linker.ld`)** | Define o layout de memória a partir de `0x80000000`; organiza as seções `.text`, `.rodata`, `.data` e `.bss` |

### 🗺️ Mapa de Memória

| Endereço | Dispositivo |
|---|---|
| `0x80000000` | RAM (início do kernel) |
| `0x10000000` | UART NS16550A |
| `0x100000`   | SiFive Test (power-off/reboot) |
| `0x2000000`  | CLINT |
| `0xC000000`  | PLIC |

---

## 🛠️ Dependências

Para buildar e executar o projeto, você precisará dos seguintes utilitários instalados:

### Toolchain RISC-V

O compilador cruzado `riscv64-unknown-elf-gcc` e o linker `riscv64-unknown-elf-ld`.

#### Linux (Debian/Ubuntu)
```bash
sudo apt update
sudo apt install gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf
```

#### Linux (Arch)
```bash
sudo pacman -S riscv64-elf-gcc riscv64-elf-binutils
```

#### macOS (Homebrew)
```bash
brew tap riscv/riscv
brew install riscv/riscv/riscv-tools
```

#### Windows
Utilize o [MSYS2](https://www.msys2.org/) e instale o pacote correspondente, ou use o WSL (recomendado) seguindo as instruções do Linux acima.

---

### QEMU (para emulação)

#### Linux (Debian/Ubuntu)
```bash
sudo apt install qemu-system-misc
```

#### Linux (Arch)
```bash
sudo pacman -S qemu-arch-extra
```

#### macOS
```bash
brew install qemu
```

#### Windows / WSL
```bash
sudo apt install qemu-system-misc
```

---

## 🚀 Como Buildar e Executar

Clone o repositório e entre na pasta:
```bash
git clone https://github.com/A-r-ka/OS.git
cd OS
```

### Build

Compila todos os arquivos `.s` e linka o `kernel.elf`:
```bash
make
```

### Executar no QEMU (com interface gráfica)

```bash
make run
```

### Executar no QEMU (sem interface gráfica — saída direto no terminal)

```bash
make run_nographic
```

> A saída do kernel (`Hello, World!`) aparecerá no terminal via UART.

### Executar com número customizado de harts

O número de harts padrão é **4**. Para alterar:
```bash
make run HARTS=2
```

### Debug com GDB

Instalar o GDB (MacOS):
```bash
brew install riscv64-elf-gdb
```

Inicia o QEMU aguardando conexão do GDB na porta `1234`:
```bash
make debug
```

Em outro terminal, conecte o GDB (GNU Linux):
```bash
gdb-multiarch kernel.elf
(gdb) target remote :1234
(gdb) continue

Em outro terminal, conecte o GDB (MacOS):
```bash
riscv64-elf-gdb kernel.elf
(gdb) target remote :1234
(gdb) continue
```

### Limpar arquivos compilados

```bash
make clean
```

---

## 📁 Estrutura do Projeto

```
OS/
├── boot.s              # Ponto de entrada do kernel (_start)
├── linker.ld           # Script do linker — define o layout de memória
├── makefile            # Sistema de build
├── kernel.elf          # Binário gerado (após build)
│
├── drivers/
│   └── uart.s          # Driver UART NS16550A (putc, printf, init)
│
├── obj_compiled/       # Objetos intermediários gerados pelo build
│
└── virt_dtb/
    ├── virt.dts        # Device Tree Source da máquina virtual QEMU
    └── virt.dtb        # Device Tree Blob (binário compilado)
```

---

## ⚙️ Flags de Compilação

| Flag | Descrição |
|---|---|
| `-march=rv64g` | Arquitetura alvo: RV64 com extensões IMAFD |
| `-mabi=lp64` | ABI de 64-bit sem ponto flutuante em registradores |
| `-mcmodel=medany` | Modelo de código para endereços arbitrários de 64-bit |
| `-ffreestanding` | Sem presunção de ambiente de runtime padrão |
| `-nostdlib` | Não linka contra a libc |
| `-g` | Inclui informações de debug |

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para abrir uma *issue* ou *pull request*.

---

## 📄 Licença

Este projeto está licenciado sob a licença MIT. Consulte o arquivo `LICENSE` para mais detalhes.
