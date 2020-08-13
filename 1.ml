open Printf

let () =
  printf "    .global main\n";
  printf "main:\n";
  printf "    mov     r0, #42\n";
  printf "    mov     r7, #1\n";
  printf "    svc     0\n"
