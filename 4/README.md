# Variables

This version of the compiler introduces variable definitions. In order to accommodate this it uses Ocamllex and Menhir to parse a more advanced ML-like syntax and the Dune build system to manage code generation and compilation.

Build this compiler with:

    $ dune build
          menhir parser.{ml,mli}
    Built an LR(0) automaton with 27 states.
    The construction mode is pager.
    Built an LR(1) automaton with 27 states.
    36 shift/reduce conflicts were silently solved.
    Warning: one state has shift/reduce conflicts.
    Warning: 6 shift/reduce conflicts were arbitrarily resolved.

Run it and enter a suitable program with:

    $ ./_build/default/compiler.exe 
    Give me an expression in ML syntax like "let x = 3 in x*(x+1)"
    > let x = 3 in x*(x+1)
