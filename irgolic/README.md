## Setup

Initialize your development shell with `nix develop -C $SHELL`

## Running

`generate_list.py` generates the non-primitive words via templating – it creates templates like XYXY and substitutes every possible combination of numbers into them. This may be construed as cheating – it's fast for constructing a list of numbers.  
Usage example: `uv run generate_list.py`

`check_nonprimitive.py` attempts to check whether a single number is a non-primitive word.  
Usage: `uv run check_nonprimitive.py <number-to-check>`  
Usage example: `uv run check_nonprimitive.py 123456712345671234567`

`benchmark_nonprimitive.sh` generates random primitive and non-primitive words, runs `check_nonprimitive.py` for each number, measures how long the script takes to execute, and prints statistics. Specifically, it uses `n` primitive words and `n` non-primitive words, each between `min-digits` and `max-digits` long.  
Usage: `./benchmark_nonprimitive.sh <n> <min-digits> <max-digits>`  
Usage example: `./benchmark_nonprimitive.sh 100 4 8`