(*
Minimal compiler

Our abstract syntax tree can only convey a single int that we
read from the compiler's command line arguments. This compiler
emits a movw and movt sequence to inject the required int into
the generated assembly.

Register R0 is used to hold the int.
*)

open Printf

type expr =
  | Int of int

let emit = function
  | Int n ->
    printf "    movw    r0, %d\n" (n land 0xffff);
    printf "    movt    r0, %d\n" ((n lsr 16) land 0xffff)

let () =
  eprintf "Give me an int:\n> %!";
  let n = read_int() in
  eprintf "Generating Arm assembly for %d\n" n;
  printf "    .global _start\n";
  printf "_start:\n";
  emit(Int n);
  printf "    mov     r7, #1\n";
  printf "    svc     0\n"
