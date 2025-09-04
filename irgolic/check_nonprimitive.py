#!/usr/bin/env python3

def is_nonprimitive_fast(n: int) -> bool:
    """
    Fast check if a number is non-primitive using direct digit pattern analysis.
    O(d²) where d is number of digits.
    """
    s = str(n)
    d = len(s)
    
    # Check all possible periods (divisors of d)
    for period in range(1, d):
        if d % period != 0:
            continue
        
        # Check if string repeats with this period
        is_periodic = True
        for i in range(d):
            if s[i] != s[i % period]:
                is_periodic = False
                break
        
        if is_periodic:
            return True
    
    return False


def is_nonprimitive_optimized(n: int) -> bool:
    """
    More optimized version that stops early and uses string slicing.
    """
    s = str(n)
    d = len(s)
    
    # Check periods from smallest to largest for early exit
    for period in range(1, d):
        if d % period != 0:
            continue
        
        # Use string slicing for faster comparison
        pattern = s[:period]
        repetitions = d // period
        
        if pattern * repetitions == s:
            return True
    
    return False


def is_nonprimitive_math(n: int) -> bool:
    """
    Mathematical approach using modular arithmetic (fastest for very large numbers).
    """
    s = str(n)
    d = len(s)
    
    for period in range(1, d):
        if d % period != 0:
            continue
        
        # Check if n ≡ n/10^period (mod (10^period - 1)/gcd(...))
        # This is more complex but avoids string operations for huge numbers
        base_pow = 10 ** period
        quotient = n // base_pow
        remainder = n % base_pow
        
        # For exact repetition: n = quotient * (10^period + 10^(2*period) + ...)
        repetitions = d // period
        expected = quotient * sum(base_pow ** i for i in range(repetitions))
        
        if n == expected and quotient == remainder:
            return True
    
    return False


if __name__ == "__main__":
    import sys
    
    if len(sys.argv) != 2:
        print("Usage: python check_nonprimitive.py <number>")
        sys.exit(1)
    
    try:
        number = int(sys.argv[1])
        result = is_nonprimitive_optimized(number)
        print(f"{number}: {'non-primitive' if result else 'primitive'}")
    except ValueError:
        print("Error: Please provide a valid integer")
        sys.exit(1)