(*
Static code generation

This program just spits out constant assembly so it isn't really
a compiler.

To avoid a dependency on the C stdlib we provide the _start function
directly and use an Arm software interrupt equivalent to C's
"exit(42);".
*)

open Printf

let () =
  printf "    .global _start\n";
  printf "_start:\n";
  printf "    mov     r0, #42\n";
  printf "    mov     r7, #1\n";
  printf "    svc     0\n"
