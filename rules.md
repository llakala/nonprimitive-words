# What are the rules?

Your program should define a function that, given any number, returns whether
it's a **non-primitive word**.

A nonprimitive word can be constructed through concatenating its substrings.
Here are some examples:

- 111
- 2323
- 189189

Here are some NON-examples:
- 121 (palindrome, but no substring to construct it)
- 1 (the substring needs to repeat at least once)

For more, see the [OEIS entry](https://oeis.org/A239019), and the [list of the
first 10,000 elements of the set](https://oeis.org/A239019/b239019.txt).

# Can't I just...

There are some ways to trivialize this, which aren't allowed. Some of these are
cool in their own ways, but if we allowed them, the spirit of the competition
would go away. You can't:

1. Precompute anything meaningful

Precomputing the factors of the first 10 numbers is fine - that's not exactly
meaningful. But if you precomputed the correct split for every number, that's
only a step away from reading the correct values from a text file

2. Construct the outputs rather than looping through all numbers

Rather than checking if a given number was non-primitive, you could
hypothetically just make all the primitives, and then concatenate them together
for larger versions. But where's the fun in that? The idea of the challenge is
to optimize your ability to determine WHETHER a number is primitive - not WHAT
numbers are primitive. We just loop through numbers for testing purposes.

# How do I share my solution?

Put your code in a folder with your Github username! While it's not required,
it's encouraged to provide a way to reproduce your result. If you SAY your code
is the fastest, but we can't run it, how do we know you're telling the truth?

Be reproducible in however suits you best - a file with instructions, a
devshell, whatever.

Also, make sure that your solution gets the same results as other people's
solutions! To make sure, dump the command output to a file with `> output`, and
diff yours with someone else's. You should get 1107 solutions from 1 to 10
million.

Thanks for playing! Have fun.
