#!/usr/bin/env python3

import numpy as np
from collections import defaultdict
from typing import Iterator, Set, Tuple
import sys


class NonPrimitiveGenerator:
    """
    Optimized generator for non-primitive numbers using template-based vectorization.
    """
    
    def __init__(self, base: int = 10):
        self.base = base
        self.template_cache = {}
        self.rgs_cache = {}
        
    def generate_rgs_cached(self, n: int) -> list:
        """Generate restricted growth strings with caching."""
        if n in self.rgs_cache:
            return self.rgs_cache[n]
        
        if n == 0:
            result = [[]]
        elif n == 1:
            result = [[0]]
        else:
            result = []
            def backtrack(current, max_label):
                if len(current) == n:
                    result.append(current[:])
                    return
                for label in range(min(max_label + 2, n)):
                    current.append(label)
                    backtrack(current, max(max_label, label))
                    current.pop()
            backtrack([0], 0)
        
        self.rgs_cache[n] = result
        return result
    
    def generate_from_template_batch(self, template: str, min_val: int, max_val: int) -> np.ndarray:
        """
        Generate numbers from template with early bounds checking.
        """
        d = len(template)
        labels = np.array([int(c) for c in template], dtype=np.int8)
        
        uniq_labels, inverse = np.unique(labels, return_inverse=True)
        K = len(uniq_labels)
        lead_label = inverse[0]
        
        ranges = []
        for k in range(K):
            if k == lead_label:
                ranges.append(np.arange(1, self.base, dtype=np.int8))
            else:
                ranges.append(np.arange(0, self.base, dtype=np.int8))
        
        powers = self.base ** np.arange(d - 1, -1, -1, dtype=np.int64)
        
        label_powers = np.zeros(K, dtype=np.int64)
        for i, label in enumerate(inverse):
            label_powers[label] += powers[i]
        
        min_digits = np.zeros(K, dtype=np.int8)
        max_digits = np.full(K, self.base - 1, dtype=np.int8)
        min_digits[lead_label] = 1
        
        min_possible = np.dot(min_digits, label_powers)
        max_possible = np.dot(max_digits, label_powers)
        
        if min_possible > max_val or max_possible < min_val:
            return np.array([], dtype=np.int64)
        
        if K <= 3:
            grids = np.meshgrid(*ranges, indexing='ij')
            assignments = np.column_stack([g.ravel() for g in grids])
            numbers = assignments @ label_powers
        else:
            numbers = []
            def iterate_assignments(idx=0, current=[]):
                if idx == K:
                    num = np.dot(current, label_powers)
                    if min_val <= num <= max_val:
                        numbers.append(num)
                    return
                
                for digit in ranges[idx]:
                    current.append(digit)
                    partial = np.dot(current, label_powers[:len(current)])
                    min_remaining = np.dot(min_digits[len(current):], label_powers[len(current):])
                    max_remaining = np.dot(max_digits[len(current):], label_powers[len(current):])
                    
                    if partial + min_remaining <= max_val and partial + max_remaining >= min_val:
                        iterate_assignments(idx + 1, current)
                    current.pop()
            
            iterate_assignments()
            numbers = np.array(numbers, dtype=np.int64)
        
        mask = (numbers >= min_val) & (numbers <= max_val)
        return numbers[mask]
    
    def generate_for_digit_length(self, d: int, min_val: int, max_val: int) -> Set[int]:
        """Generate all non-primitive numbers of length d."""
        results = set()
        
        for period in range(1, d):
            if d % period != 0:
                continue
            
            repetitions = d // period
            patterns = self.generate_rgs_cached(period)
            
            for pattern in patterns:
                template = ''.join(str(x) for x in pattern * repetitions)
                
                nums = self.generate_from_template_batch(template, min_val, max_val)
                results.update(nums.tolist())
        
        return results
    
    def generate_up_to(self, limit: int) -> Iterator[int]:
        """Generate all non-primitive numbers up to limit."""
        max_digits = len(str(limit - 1))
        
        for d in range(2, max_digits + 1):
            min_d = self.base ** (d - 1) if d > 1 else self.base
            max_d = min(self.base ** d - 1, limit - 1)
            
            if min_d >= limit:
                break
            
            nums = self.generate_for_digit_length(d, min_d, max_d)
            
            for num in sorted(nums):
                yield num


def main():
    """Optimized main function."""
    limit = 10000000
    generator = NonPrimitiveGenerator(base=10)
    
    with open('output', 'w') as f:
        for num in generator.generate_up_to(limit):
            f.write(f"{num}\n")


def main_parallel_chunks():
    """
    Alternative implementation that processes in chunks for better memory usage.
    """
    limit = 10000000
    generator = NonPrimitiveGenerator(base=10)
    
    results = []
    chunk_size = 100000
    
    for start in range(10, limit, chunk_size):
        end = min(start + chunk_size, limit)
        chunk_results = []
        
        min_d = len(str(start))
        max_d = len(str(end - 1))
        
        for d in range(min_d, max_d + 1):
            min_val = max(10 ** (d - 1), start)
            max_val = min(10 ** d - 1, end - 1)
            
            if min_val >= end:
                continue
            
            nums = generator.generate_for_digit_length(d, min_val, max_val)
            chunk_results.extend(nums)
        
        results.extend(sorted(chunk_results))
    
    with open('output', 'w') as f:
        for num in sorted(set(results)):
            f.write(f"{num}\n")


if __name__ == "__main__":
    main()