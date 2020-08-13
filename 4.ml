open Printf

type binOp = Add | Sub

type expr =
  | Int of int
  | BinOp of expr * binOp * expr
  | Putchar of expr

let rec emit_expr = function
  | Int n ->
    printf "    movw    r11, %d\n" (n land 0xffff);
    printf "    movt    r11, %d\n" ((n lsr 16) land 0xffff);
    printf "    push    {r11}\n"
  | BinOp(f, op, g) ->
    emit_expr f;
    emit_expr g;
    printf "    pop     {r10, r11}\n";
    let op =
      match op with
      | Add -> "add"
      | Sub -> "sub" in
    printf "    %s     r11, r11, r10\n" op;
    printf "    push    {r11}\n"
  | Putchar f ->
    emit_expr f;
    printf "    pop     {r0}\n";
    printf "    push    {r0, r1, r2, r7}\n";
    printf "    mov     r0, #0\n";
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
  emit_expr(Putchar(BinOp(Int n, Sub, Int 1)));
  printf "    mov     r7, #1\n";
  printf "    svc     0\n"
