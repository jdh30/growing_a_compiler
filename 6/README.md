# Pattern matching

This version of the compiler introduces support for conditional execution in the form of pattern matching and weighs in at 258 lines of code.

Here is an example:

    $ ./run.sh
    Building compiler...
    Running compiler...
    Give me an expression in ML syntax like "(fun n -> match n with 0 -> 0 | n -> n-1) 3"
    > (fun n -> match n with 0 -> 0 | n -> n-1) 3
    Generating Arm assembly for ((fun n -> (match n with 0 -> 0 | n -> sub (n, 1))))(3)
    Assembling generated program...
    Running executable and printing exit code...
    2

Note that this version also handles negative numbers and uses a different representatio of the stack that allows each slot to have multiple names.
