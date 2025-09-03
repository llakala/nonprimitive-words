# What is this?

This is a repo consisting of people's attempts to calculate whether a number is
a **nonprimitive word** as fast as possible.

Each program defines a function that, given any number, returns whether it's a
non-primitive word. The function is then typically run for all numbers from
1 to 10 million. However, the goal is to create a generic function - checking a
large set of numbers is just a good way of determining how efficient a function
may be.

# Okay, what's a nonprimitive word?

A nonprimitive word is a sequence of characters that could be constructed by
concatenating some string with itself multiple times. This can intuitively be
thought of as the initial part of the string repeating at least once.

Nonprimitive words are a general concept for any set of characters. For example,
`abcabc` is a valid solution. However, this repo only focuses on nontrivial
words made up of the digits 0-9.

Here are some examples of nonprimitive words:

- 111 (1 repeating three times)
- 2323 (23 repeating two times)
- 189189 (189 repeating two times)

Here are some NON-examples:

- 1 (the substring needs to repeat at least once)
- 189 (again, the substring must repeat again)

One specific non-example which often trips people up is 1221. This is **not** a
nonprimitive word. If it was, it would have some initial substring that could be
repeated to construct the rest of the word. But repeating 1 gives 1111, and
repeating 12 gives us 1212. Therefore, 1221 isn't a valid solution.

For more, see the [OEIS entry](https://oeis.org/A239019), and the [list of
the first 10,000 elements of the set](https://oeis.org/A239019/b239019.txt).

# How do I share my solution?

If you have some code that solves this, and you'd like to share it, you can:

1. Make a PR
1. Ask for commit access and commit it yourself

If you want to be a committer, just pinky promise that you'll only touch *your*
solution, and won't mess with other people's code. I don't want to make everyone
do PRs, but if people abuse commit access, I'll have to be stricter.

Once you have access, put your code in a folder named after your Github
username. While it's not required, it's encouraged to provide _some_ way to
reproduce your result. We have infrastructure set up which allows you to package
your program through Nix (see other people's code for examples). However, if
you're not feeling nixy today, providing a text file with commands to run is
good enough.

Make sure that your program is actually getting the right results. You can dump
your output to a file with `> output.txt`, and diff it with the output of
someone else's program. You should get 1107 solutions from 1 to 10 million.

# What are the rules?

The goal of this repo is to allow people to share solutions - and too many
unnecessary rules would stifle that. However, there are a few "suggestions" to
follow. If you think you can do something cool in a way that doesn't follow
these suggestions, just note that, and go to town.

1. Avoid precomputing where possible

Precomputing can make things very fast. However, taking precomputing to its
natural extension, the "optimal" solution is to write all the answers down, and
print them out at runtime. Rather than writing down data in a file and reading
from it, see if you can instead generate that data at runtime, and cache it for
quick access.

2. Try to make a generalizable function

The 1 to 10 million range is used so people can compare their programs easily.
If your code ONLY works for this range, it's a little boring. If you have a cool
optimization that only works for small inputs, feel free to use it - but see if
it's possible to fall back to slower methods if the input is too large, rather
than rejecting the input or giving the wrong solution.

# Final (most important) rule

Have fun! A cheaty solution is fine if it's cool.
