open Printf

type expr =
  | Int of int
  | Add of expr * expr
  | Putchar of expr

let rec emit_expr = function
  | Int n ->
    printf "    movw    r11, %d\n" (n land 0xffff);
    printf "    movt    r11, %d\n" ((n lsr 16) land 0xffff);
    printf "    push    {r11}\n"
  | Add(f, g) ->
    emit_expr f;
    emit_expr g;
    printf "    pop     {r10, r11}\n";
    printf "    add     r11, r10, r11\n";
    printf "    push    {r11}\n"
  | Putchar f ->
    emit_expr f;
    printf "    pop     {r0}\n";
    printf "    push    {r0, r1, r2, r7}\n";
    printf "    mov     r0, #1\n";
    printf "    mov     r1, sp\n";
    printf "    mov     r2, #1\n";
    printf "    mov     r7, #4\n";
    printf "    svc     0\n";
    printf "    pop     {r0, r1, r2, r7}\n"

let () =
  let n =
    match Sys.argv with
    | [|_; n|] -> int_of_string n
    | _ -> 42 in
  printf "    .global main\n";
  printf "main:\n";
  emit_expr(Putchar(Add(Add(Int n, Int n), Int n)));
  printf "    mov     r7, #1\n";
  printf "    svc     0\n"
