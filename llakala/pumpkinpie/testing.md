For getting the time to execute, do:
```sh
nix shell github:nixos/nixpkgs/dfb2f12e899db4876308eba6d93455ab7da304cd#pyp
time pypy foo.py
```

You don't have to use that commit, but pypy was building manually on notarin's
machine, and this one is guaranteed to work
