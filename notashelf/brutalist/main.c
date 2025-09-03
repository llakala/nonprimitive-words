/*
A number's decimal string is non-primitive if it is k >= 2 repeats of a shorter
block.

Let length = L, candidate period length = d (d | L, 1 <= d < L), prefix P =
first d digits.

Repetition condition: n = P * (10^L - 1) / (10^d - 1)
Equivalent cross-multiplication test:

    n * (10^d - 1) == P * (10^L - 1)

We precompute powers of 10 (POW10[]) and for each possible L (1..19) a short
list of proper divisors (DIVS[L]) ordered largest-first for earlier exits.

Algorithm per n:
  1. Determine L by threshold comparisons.
  2. For each d in DIVS[L]:
    - Fast path d==1: check all digits identical (homogeneous digit string).
    - Otherwise extract prefix P = n / 10^(L - d) and test the identity above
      using 128-bit intermediates to avoid overflow.
  3. First success => non-primitive; otherwise primitive.

Homogeneous-digit optimization avoids 128-bit multiplies for prime lengths
(where the only possible repetition is a single digit repeated).

The divisor list encodes all needed period lengths. Example for small L:
  L=2:      (a)^2
  L=3:      (a)^3
  L=4:      (ab)^2, (a)^4
  L=6:      (abc)^2, (ab)^3, (a)^6
  L=8:      (abcd)^2, (ab)^4, (a)^8

General lengths up to 19 handled analogously (full 64-bit range).
Time per number is constant (=<5 candidate checks, usually 1).

P.S. so sorry for my comment format
*/
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#if defined(__GNUC__) || defined(__clang__)
#define INLINE static __attribute__((always_inline)) inline
#else
#define INLINE static inline
#endif

static const uint64_t POW10[20] = {1ULL,
                                   10ULL,
                                   100ULL,
                                   1000ULL,
                                   10000ULL,
                                   100000ULL,
                                   1000000ULL,
                                   10000000ULL,
                                   100000000ULL,
                                   1000000000ULL,
                                   10000000000ULL,
                                   100000000000ULL,
                                   1000000000000ULL,
                                   10000000000000ULL,
                                   100000000000000ULL,
                                   1000000000000000ULL,
                                   10000000000000000ULL,
                                   100000000000000000ULL,
                                   1000000000000000000ULL,
                                   10000000000000000000ULL};

static const unsigned char DIVS[20][6] = {{0},
                                          {0},
                                          {1, 0},
                                          {1, 0},
                                          {2, 1, 0},
                                          {1, 0},
                                          {3, 2, 1, 0},
                                          {1, 0},
                                          {4, 2, 1, 0},
                                          {3, 1, 0},
                                          {5, 2, 1, 0},
                                          {1, 0},
                                          {6, 4, 3, 2, 1, 0},
                                          {1, 0},
                                          {7, 2, 1, 0},
                                          {5, 3, 1, 0},
                                          {8, 4, 2, 1, 0},
                                          {1, 0},
                                          {9, 6, 3, 2, 1, 0},
                                          {1, 0}};

INLINE unsigned dec_len_u64(uint64_t n) {
  if (n >= 1000000000000000000ULL)
    return 19;
  if (n >= 100000000000000000ULL)
    return 18;
  if (n >= 10000000000000000ULL)
    return 17;
  if (n >= 1000000000000000ULL)
    return 16;
  if (n >= 100000000000000ULL)
    return 15;
  if (n >= 10000000000000ULL)
    return 14;
  if (n >= 1000000000000ULL)
    return 13;
  if (n >= 100000000000ULL)
    return 12;
  if (n >= 10000000000ULL)
    return 11;
  if (n >= 1000000000ULL)
    return 10;
  if (n >= 100000000ULL)
    return 9;
  if (n >= 10000000ULL)
    return 8;
  if (n >= 1000000ULL)
    return 7;
  if (n >= 100000ULL)
    return 6;
  if (n >= 10000ULL)
    return 5;
  if (n >= 1000ULL)
    return 4;
  if (n >= 100ULL)
    return 3;
  if (n >= 10ULL)
    return 2;
  return 1;
}

INLINE int all_digits_same(uint64_t n) {
  unsigned d = (unsigned)(n % 10ULL);
  uint64_t t = n / 10ULL;
  while (t) {
    if ((t % 10ULL) != d)
      return 0;
    t /= 10ULL;
  }
  return 1;
}

INLINE int is_nonprimitive(uint64_t n) {
  unsigned L = dec_len_u64(n);
  if (L == 1)
    return 0;

  const unsigned char *dv = DIVS[L];
  uint64_t repLminus1 = POW10[L] - 1ULL;

  for (unsigned char d; (d = *dv++) != 0;) {
    if (d == 1) {
      if (all_digits_same(n))
        return 1;
      continue;
    }
    uint64_t prefix = n / POW10[L - d];
    uint64_t repDminus1 = POW10[d] - 1ULL;
    __uint128_t left = (__uint128_t)n * repDminus1;
    __uint128_t right = (__uint128_t)prefix * repLminus1;
    if (left == right)
      return 1;
  }
  return 0;
}

int main(int argc, char **argv) {
  uint64_t limit = 10000000ULL;
  if (argc > 1) {
    char *endp = 0;
    uint64_t v = strtoull(argv[1], &endp, 10);
    if (endp && *endp == '\0' && v > 0)
      limit = v;
    else if (v == 0) {
      puts("0");
      return 0;
    }
  } else {
    fprintf(stderr, "Usage: %s <limit>\nDefaulting to 10,000,000\n", argv[0]);
  }

  uint64_t count = 0;
  for (uint64_t n = 1; n <= limit; ++n)
    count += (unsigned)is_nonprimitive(n);

  printf("%llu\n", (unsigned long long)count);
  return 0;
}
