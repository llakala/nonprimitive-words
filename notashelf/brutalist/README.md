## Building

<!-- markdownlint-disable MD013 -->

```bash
# Build with GCC
nix-shell -p gcc --run "gcc -O3 -fomit-frame-pointer -pipe -DNDEBUG -o brutalist main.c"
# Run the program
./brutalist
```

You can also create your own static builds using Nix

```bash
# Build with musl
nix-shell -p musl gcc --run "musl-gcc -O3 -static -s -fomit-frame-pointer -DNDEBUG -o brutalist-static main.c"

# Run the program
./brutalist-static
```

<!-- markdownlint-enable MD013 -->

## Usage

Unlike the assembly variant, I've decided to parse arguments this time. Namely,
you can insert the upper bound.

```bash
./nonprimitive <limit>
```

For example:

```bash
$ ./nonprimitive 10000000
#=1107
```

If no argument is supplied, we default to 10,000,000 and print the usage info to
`stderr.`

### Notes

This is a fun implementation. The time complexity of this solution is O(N). Per
number, it's O(1) with a small constant. Upper bound candidate checks per
length:

- Prime lengths: 1 (homogeneous digits test)
- Composite worst cases: `L=12` or `18` => 5 divisor candidates
- Average candidate count across `1..10^k` ranges ≈ 1–2.

We have two small constant tables:

- `POW10[0..19]`
- Proper divisors list `DIVS[0..19]`

Which I'm pretty sure is on thin ice for the challenge rules. Oh and the space
complexity is O(1). Yeah.

On that note though, there is no dynamic allocation, no caching of previously
seen numbers and no precomputed answer file so I _**think**_ we're good.

#### ~~Why~~ How Does It Work?

This is a vastly improved version of the [Assembly version](../steampunk/) of
the same solver. Ultimately both programs perform the same mathematical test:
_Is the decimal string of `n` made of smaller blocks repeated `k>=2` times?_ The
underlying mathematical condition is identical in the two forms and comes from
writing a repeated block as a geometric series.

```math
n = P * (10^L - 1) / (10^d - 1)
```

Rearranging gives the equality

```math
n * (10^d - 1) = P * (10^L - 1)
```

The C variant uses exactly that rearranged identity. It computes the length `L`
with a fixed comparison ladder, loops over the proper divisors `d` of `L`,
extracts the prefix `P` once per candidate by dividing by `10^{L-d}`, and tests
the cross‑multiplication equality with widened (128‑bit) intermediates so
nothing overflows. A special shortcut handles the `d = 1` case by directly
checking that all digits are the same without doing the 128‑bit multiply. No
masks are stored; only powers of ten and divisor lists are needed.

The assembly variant encodes the same condition in a complementary way. Instead
of forming `P` first and cross‑multiplying, it precomputes, implicitly or
explicitly, the "mask" constants

```math
M = (10^L - 1) / (10^d - 1)
```

and then tests whether `n` is divisible by `M`. If `n % M == 0`, the quotient is
the candidate block value. A size check on the quotient enforces that the block
does not gain a leading zero (its digit count must be exactly `d`). That
divisibility condition is algebraically equivalent to the identity the C code
checks. Multiplying both sides of `n = P * M` by `(10^d - 1)` reproduces the
same cross‑multiplication relation. Awesome.

In short (not really, I'll keep yapping) the difference is _procedural_ and not
mathematical. I think the formula we're going with is the way to go, but the C
version derives the prefix and then verifies equality. The assembly variant on
another hand tests divisibility by a mask, and then verifies the quotient fits.

Naturally the C approach tends to use cheaper operations on modern CPUs
(strength‑reduced division by powers of ten plus multiplies) while the assembly
form as written leans on hardware division by non power‑of‑ten constants.
Extending the C variant to larger limits only needs more divisor entries
(already covers up to 19 digits); extending the assembly variant requires
introducing larger mask constants and ensuring they still fit comfortably in the
chosen register width. You can decide which is the optimal solution.

Lastly the leading zero cases are automatically excluded, because the prefix is
taken from the true digit span. Assembly path excluded them explicitly via the
quotient digit‑length check.

#### Correctness? I Barely Know Her

Here are a few notes on the "correctness" of this program that I feel

- Leading zero periods are impossible because prefix extraction uses integer
  division based on true decimal length (a leading zero would imply smaller
  length).
- 128-bit intermediates guarantee no overflow for: `left = n*(10^d - 1)` and
  `right = prefix*(10^L - 1)` when `n < 10^{19}`.
- Length 1 numbers immediately rejected.

#### Future Work

- We might be able to pre-unroll divisor loops for the composite lengths
  (12, 18) if targeting a very tight core.
- Provide a compile-time `#define MAX_LEN` to prune unreachable length branches
  when limiting `limit < 10^{MAX_LEN}`.
- Replace the digit-scan for `d=1` with a multiply+compare trick for repunits if
  profiling shows benefit (rare).

Additionally it's technically possible, though I think wildly out of scope, to
support > 19 digit args. For such a program we'd use the 128-bit built-in type
(`__int128`) that still allows length `=< 38` with same identity before overflow
in intermediates (careful with `(10^L - 1)` growth). After that, switch to
string / chunk comparisons or multi-precision big integers (would increase
constant factors).
