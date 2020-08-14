open Printf

let () =
  printf "    .global _start\n";
  printf "_start:\n";
  printf "    mov     r0, #42\n";
  printf "    mov     r7, #1\n";
  printf "    svc     0\n"
