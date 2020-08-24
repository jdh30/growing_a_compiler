# Recursion

This version of the compiler implements recursion and weighs in at 279 lines of code.

The generated code is around 5x slower than ocamlopt and slightly faster than ocamlc.

Here is an example:

    $ ./run.sh
    Building compiler...
    Running compiler...
    Give me an expression in ML syntax like "let f = fun n -> match n with 0 | 1 -> n | n -> f(n-2)+f(n-1) in f 10"
    > let f = fun n -> match n with 0 | 1 -> n | n -> f(n-2)+f(n-1) in f 40
    Generating Arm assembly for let f = (fun n -> (match n with 0 | 1 -> n | n -> add ((f)(sub (n, 2)), (f)(sub (n, 1))))) in (f)(40)
    Assembling generated program...
    Running executable and printing exit code...
    203

    real    0m9.453s
    user    0m9.407s
    sys     0m0.010s

