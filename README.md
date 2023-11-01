# brainfukd
A brainfuck interpreter written in D while using -betterC flag

## Requirements
- dub

## Usage
In project root
- `dub run -- FILENAME`
Or
-- `dub build`
-- `./bin/brainfukd FILENAME`

## Known issues
Some programs that are continuously reading user input might get stuck on infinite loop since brainfukd reads user input as it goes, meaning when it encounters `,` it prompts for input where you can put as many characters as you want.
