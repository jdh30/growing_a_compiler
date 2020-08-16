# Growing a Compiler

This repository details my attempts to grow a compiler. I was initially inspired to pursue this idea by an excellent paper ["An Incremental Approach to Compiler Construction"](http://scheme2006.cs.uchicago.edu/11-ghuloum.pdf) by Abdulaziz Ghuloum and a [wonderful presentation](https://www.youtube.com/watch?v=WBWRkUuyuE0) about it by Jaseem Abid where they described how to grow a compiler that translates Scheme into x86 assembly. The final push I needed was the superb book [Compiling to Assembly from scratch](https://keleshev.com/compiling-to-assembly-from-scratch/) by Vladimir Keleshev that describes a compiler written in Typescript that generates 32-bit Arm assembly and has an elegant [partial OCaml port](https://github.com/keleshev/compiling-to-assembly-from-scratch/tree/main/contrib/ocaml).

My objective with this project is slightly different. I wish to avoid run-time type information and checks at all costs and use a C-like data representation instead. I plan to achieve this using a statically-typed language of the ML family. My compilers are written in OCaml and generate 32-bit Arm assembly (aka A32) ideal for a Raspberry Pi 4.

The `run.sh` script makes it easy to run any version. For example, run version 3 with:

    $ ./run.sh 3 22
    Running OCaml code...
    Give me an expression in reverse Polish notation like 2 3 + 4 * 5 /:

Enter a suitable expression at the prompt:

    > 2 3 +

And observe the result:

    Generating Arm assembly for add (2, 3)
    Compiling generated assembly...
    Running executable...
    5

The features added to each version are:

1. Static generation of assembly
2. Dynamic generation of the given int
3. Binary operators and reverse Polish notation
4. Variables (let bindings and variable lookup) and s-expression syntax
5. Functions

## To do

* Conditional execution and pattern matching
* Tuples
* Arrays
* Read and write
* Abstract representation of the instruction set
* Virtualize the stack and put top elements in registers when possible
* Use liveness analysis to reuse registers
* Generate machine code to make a JIT
* Calling conventions and a FFI
