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

### Can you Elaborate?

Yes, yes I can. Thank you for asking.

So, a number is counted **if its decimal string can be written as B repeated k
times with `k >= 2` and B having no leading zero**. For example, 2323 is "23"
repeated 2 times; 189189 is"189" repeated 2 times. Single-digit numbers and
numbers whose only decomposition would require a leading zero in a block are
excluded. If the length of the number is **`L`** and the period (block length)
is **`p`** (`p` divides `L`), then:

<!-- TODO: express this with LaTeX? -->

```plaintext
N = B * (10^{p(k-1)} + 10^{p(k-2)} + ... + 10^{p} + 1)
```

The multiplier is a geometric series = `(10^{pk} − 1) / (10^{p} − 1)`. For small
fixed `L` (`=< 8` here), each possible `p` gives us a fixed decimal "mask"
constant.

#### Constants

We classify by digit length (**`L`**) using threshold compares (no division for
length detection). For each length we test divisibility by the precomputed mask
constants:

<!-- markdownlint-disable MD013 -->

| L | Period structures tested      | Mask constants           | Interpretation      |
| - | ----------------------------- | ------------------------ | ------------------- |
| 2 | `(a)^2`                       | 11                       | aa                  |
| 3 | `(a)^3`                       | 111                      | aaa                 |
| 4 | `(a)^4`, `(ab)^2`             | 1111, 101                | aaaa, abab          |
| 5 | `(a)^5`                       | 11111                    | aaaaa               |
| 6 | `(a)^6`, `(ab)^3`, `(abc)^2`  | 111111, 10101, 1001      | a×6, ab×3, abcabc   |
| 7 | `(a)^7`                       | 1111111                  | a×7                 |
| 8 | `(a)^8`, `(ab)^4`, `(abcd)^2` | 11111111, 1010101, 10001 | a×8, ab×4, abcdabcd |

<!-- markdownlint-enable MD013 -->

If `N % mask == 0` we obtain the candidate block value (the quotient). We then
ensure the quotient fits in the expected number of digits (prevents hidden
leading zeros). For example, for `(ab)^2` (mask 101), quotient must be `< 100`
(two digits); for `(abcd)^2` (mask 10001), quotient is `< 10000`.

#### Steps

<!-- markdownlint-disable MD033 -->

The program consists of 5 <bullshit>simple</bullshit> steps.

<!-- markdownlint-disable MD033 -->

1. Loop `n` from 1 to 10,000,000 (inclusive).
2. Determine `L` by comparing against powers of 10 (chain of `cmp/jb`).
3. Dispatch to a small block with at most 1–3 `div` instructions testing the
   mask constants for that length.
4. On first successful test (divides cleanly and quotient digit-size valid)
   increment the non-primitive counter.
5. After the loop, convert the counter to decimal and write it with a single
   `write()` syscall.

## What Else

I'm pretty happy with the current implementation. However, it might be possivle
to extend the program in the future by:

- Replacing divisions with reciprocal multiplication (strength reduction) for
  further speed.
- Generic path for >8 digits generating mask constants on the fly using 64-bit
  safe ranges until overflow, then fall back to a digit-array method.

## Nerd

:(

---

This shit made me sweat.
