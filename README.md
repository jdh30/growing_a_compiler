# Growing a Compiler

This repository details my attempts to grow a compiler. I was initially inspired to pursue this idea by an excellent paper ["An Incremental Approach to Compiler Construction"](http://scheme2006.cs.uchicago.edu/11-ghuloum.pdf) by Abdulaziz Ghuloum and a [wonderful presentation](https://www.youtube.com/watch?v=WBWRkUuyuE0) about it by Jaseem Abid where they described how to grow a compiler that translates Scheme into x86 assembly. The final push I needed was the superb book [Compiling to Assembly from scratch](https://keleshev.com/compiling-to-assembly-from-scratch/) by Vladimir Keleshev that describes a compiler written in Typescript that generates 32-bit Arm assembly and has an elegant [partial OCaml port](https://github.com/keleshev/compiling-to-assembly-from-scratch/tree/main/contrib/ocaml).

My objective with this project is slightly different. I wish to avoid run-time type information and checks at all costs and use a C-like data representation instead. I plan to achieve this using a statically-typed language of the ML family. My compilers are written in OCaml and generate 32-bit Arm assembly (aka A32) ideal for a Raspberry Pi 4 running the Raspberry Pi OS.


## 1. Static generation of assembly

The first version of the "compiler" isn't a compiler at all but, rather, just a program that prints out fixed assembly that always exits with the value 42.

The `run.sh` script makes it easy to run the first three versions. To run version 1 simply do:

    $ ./run.sh 1
    Running OCaml code...
    Compiling generated assembly...
    Running executable...
    42

Note that these initial versions of the compiler generate assembly programs that don't even use the C standard library and, consequently, produce tiny <1kiB executables.


## 2. Dynamic generation of the given int

Version 2 is the first "real" compiler and weighs in at just 16 lines of OCaml code. Its abstract syntax tree permits programs consisting of just a single integer. When run the compiler prompts the user for an integer to use and generates assembly that terminates with that integer as its exit code:

    $ ./run.sh 2
    Running OCaml code...
    Give me an int:

Enter a suitable number at the prompt:

    > 13

And observe the result:

    Generating Arm assembly for 13
    Compiling generated assembly...
    Running executable...
    13

Note that an exit code is treated as an unsigned byte by Linux so only integers in the range 0..255 will work.


## 3. Binary operators and reverse Polish notation

Version 3 includes support for some arithmetic (add, substract, multiply and divide) and bitwise (and, or, exclusive-or and bit-clear) data operations and, consequently, is the first version to include non-trivial syntax. In this case I chose to use reverse Polish notation because it is easily implemented using only vanilla OCaml.

    $ ./run.sh 3
    Running OCaml code...
    Give me an expression in reverse Polish notation like 2 3 + 4 * 5 /:
    > 2 3 +
    Generating Arm assembly for add (2, 3)
    Compiling generated assembly...
    Running executable...
    5

In the interests of simplicity this version of the compiler generates purely stack-based code. The many `push` and `pop` memory operations are extremely inefficient on the Arm architecture but premature optimisation is the root of all evil: I intend to build the source language up to the point where it can be benchmarked (i.e. conditionals and loops) before optimising the generated code. Once that has been accomplished the first optimisation will be register allocation and then probably inlining.

Lessons learned: I haven't used OCaml for many years and used to enjoy its support for simple and efficient inline parsers using Camlp4 including Emacs support from the Tuareg mode. Sadly, both Camlp4 and Tuareg are now deprecated and their replacements do not yet offer these features: PPX doesn't support inline parsing and Merlin doesn't appear to support either ocamllex or Menhir.


## 4. Variables

See the [dedicated README](4/README.md).


## 5. Functions

See the [dedicated README](5/README.md).


## 6. Pattern matching

See the [dedicated README](6/README.md).


## 7. Recursion

See the [dedicated README](7/README.md).


## To do

* Tuples and a simple type system
* Memory allocation: arrays
* Algebraic datatypes
* Floating point
* Generic equality, comparison, hashing, pretty printing and serialization
* Calling conventions and a FFI (IO and OpenGL)
* Bootstrap
* Development environment
* Abstract representation of the instruction set
* Register allocation
* JIT: emit machine code into executable memory
