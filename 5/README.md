# Functions

This version of the compiler introduces support for functions and weighs in at 161 lines of code.

Function definitions are implemented by jumping over a block of code that implements the function body and pushing the address of the block of code onto the stack. Function application is implemented by popping the address of the function off the stack, jumping to it and then removing the argument from the stack to leave just the return value.

This makes it possible to run some interesting code samples such as passing one function to another function as an argument:

    $ ./run.sh 
    Building compiler...
    Running compiler...  
    Give me an expression in ML syntax like "(fun f -> f(f 3)) (fun x -> x*x)"
    > (fun f -> f(f 3)) (fun x -> x*x)
    Generating Arm assembly for ((fun f -> (f)((f)(3))))((fun x -> mul (x, x)))
    Assembling generated program...
    Running executable and printing exit code...
    81

Note that these are not first-class functions because there is no support for environment capture, i.e. a function can only refer to its parameters and not to any variables from an outer scope.

Lessons learned: the ability to co-evolve code blocks (called "basic blocks" in LLVM parlance) would be cleaner than the hack of jumping over the definition of each function. In the distant future the optimiser will want the ability to re-order and inline code blocks anyway as well as replace dynamic jumps to addresses in registers with static jumps to labels whenever possible.
