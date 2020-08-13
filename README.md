# Growing a Compiler

This repository details my attempts to grow a compiler. This compiler is written in OCaml and generates 32-bit Arm assembly (aka A32) ideal for a Raspberry Pi 4.

The `run.sh` script makes it easy to run any version. For example, run version 3 with the constant 22 in the generated assembly with:

    $ ./run.sh 3 22
    B66
    
The features added to each version are:

1. Static generation of assembly
1. Dynamic generation of an int
1. Add and putchar
1. Sub (make sure the order of operands is correct)
1. Variables: let bindings and variable lookup
1. Functions

## To do

* Conditional execution
* Arrays
* Read and write
* Virtualize the stack and put top elements in registers when possible
* Use liveness analysis to reuse registers
* Calling conventions (arguments from registers or stack)
* Generate machine code to make a JIT
