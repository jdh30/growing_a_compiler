# Pattern matching

This version of the compiler introduces support for conditional execution in the form of pattern matching and weighs in at 258 lines of code.

Here is an example:

    $ ./run.sh 
    Building compiler...
          menhir parser.{ml,mli}
    Built an LR(0) automaton with 27 states.
    The construction mode is pager.
    Built an LR(1) automaton with 27 states.
    36 shift/reduce conflicts were silently solved.
    Warning: one state has shift/reduce conflicts.
    Warning: 6 shift/reduce conflicts were arbitrarily resolved.
    Running compiler...  
    Give me an expression in ML syntax like "let x = 3 in x*(x+1)"
    > let x = 3 in x*(x+1)
    Generating Arm assembly for let x = 3 in mul (x, add (x, 1))
    Assembling generated program...
    Running executable and printing exit code...
    12
