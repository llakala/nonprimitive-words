## Building

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

## Notes

The time complexity of this solution is O(N) where N is the upper bound
(10,000,000 in the provided program). The loop iterates once per integer in [1,
N]. Each iteration performs:

- A fixed chain of at most 7 length-classification comparisons (constant).
- Then, depending on digit length, at most:
  - 1 division (lengths 2,3,5,7)
  - up to 2 divisions (length 4)
  - up to 3 divisions (lengths 6,8)

Thus the per-number work is bound by a small constant; no iteration does more
than 3 `div` instructions after a length dispatch. Which means total divisions
is `=<` 3N. In practice though, it's far fewer since most paths exit early after
the first successful modulus test.

Space complexity, if it matters to this challenge, is O(1). Only a few registers
and a 32-byte buffer for decimal output is used. If generalized to numbers of
arbitrary length without hardcoded digit thresholds, determining the digit
length naively could add an `O(log10 n)` factor per number, but in this fixed
version (i.e., maximum 8 digits) that is still constant and absorbed into O(1).

This shit made me sweat.
