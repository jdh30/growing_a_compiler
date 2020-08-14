open Printf

type expr =
  | Int of int

let emit = function
  | Int n ->
    printf "    movw    r0, %d\n" (n land 0xffff);
    printf "    movt    r0, %d\n" ((n lsr 16) land 0xffff)

let () =
  let n =
    match Sys.argv with
    | [|_; n|] -> int_of_string n
    | _ -> 42 in
  printf "    .global _start\n";
  printf "_start:\n";
  emit(Int n);
  printf "    mov     r7, #1\n";
  printf "    svc     0\n"
