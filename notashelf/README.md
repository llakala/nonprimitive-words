To build:

```bash
# Get the x86-64 assembler
nix-shell -p nasm

# Build it with basic optimizations
nasm -O3 -felf64 main.asm && ld -s -o main main.o

# Run the build output
./main
```

Implementation details are in [main.asm](./main.asm)
