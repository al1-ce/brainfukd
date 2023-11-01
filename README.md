# brainfukd
A brainfuck interpreter written in D while using -betterC flag

## Requirements
- dub

## Usage
Run with dub from project root
- `dub run -- FILENAME`

Or build with `dub build` and execute as normal cli app
- `dub build`
- `./bin/brainfukd FILENAME`

## Arguments
Arguments are hard-coded to be in order of:
1. Filename
2. Optional input

Optional input can be used with programs like `test/xmastree.bf` where, if you will run it normally, it would infinitely ask for input because it expects null (zero) termination (i.e `\0` in c).

## Examples
These examples will be using programs in `test` directory.
- `./bin/brainfukd test/helloworld.bf` - Prints hello world
- `./bin/brainfukd test/xmastree.bf 12` - Prints xmas tree with size (height) 13 (12 + 1)
- `./bin/brainfukd test/sierpinski.bf` - Prints sierpinski triangle
- `./bin/brainfukd test/rot13.bf` - Takes input, encodes it with rot13 and prints out result
