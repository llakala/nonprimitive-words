# Algorithm

To check if a number is nonprimitive, this program simply:
- finds all the ways to evenly split a string
- for each of these ways `s`, split the string into that `s` even substrings
    - if all the split components are the same, return true!
- if we're done trying all the ways to split, return false

# Pseudocode

```c
str string = stringify(num)
int len = length(string)
list(int) ways_to_split = ways_to_split(len)

for number_of_substrings in ways_to_split {
    list(str) split_string = evenly_split(str, number_of_substrings)

    if all the elements of split_string are the same {
      return true
    }
}

return false
```

# Examples

## Example 1

Take the number 123456.

This number has a length of 6. Therefore, we can use the prime factors of 6, and
send that we can split it in 2, 3, or 6.

Let's try splitting it in two. Now, we have (123, 456). These aren't the same,
so this is an invalid split.

Let's try splitting in three, to get (12, 34, 56). These aren't the same, so
this is an invalid split.

Let's try splitting in six, to get (1, 2,3,4,5,6). These aren't the same, so
this is an invalid split.

We tried al the splits, and none of them worked. Therefore, 123456 is
primitive - return false.

## Example 2

Take the number 15671567.

This number has a length of 8. Therefore, we can use the prime factors of 8, to
see that we can split it in 2, 4, or 8.

Let's try splitting it in two. Now, we have (1567, 1567). These ARE the same.
Therefore, 15671567 is nonprimitive - return true.

# Testing

## Through the flake

You can use the flake, via:
```sh
nix shell .#pumpkin
time pumpkin
```

## Manually

```sh
nix shell github:nixos/nixpkgs/dfb2f12e899db4876308eba6d93455ab7da304cd#pypy3
time pypy3 llakala/pumpkin/main.py
```

You don't have to use that commit, but pypy was building manually on notarin's
machine, and this one is guaranteed to work! Don't miss that it's `pypy3`, not
normal `pypy`.
