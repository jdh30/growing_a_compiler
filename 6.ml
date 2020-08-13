(*
Variables
let bindings
Environment: variable -> location (register or stack offset)
*)

open Printf

module List = struct
  include List

  let rec skip n xs =
    match n, xs with
    | 0, xs -> xs
    | n, [] -> failwith "Skip on empty list"
    | n, _::xs -> skip (n-1) xs
end

type binOp = Add | Sub | Mul | Div

type expr =
  | Int of int
  | Var of string
  | BinOp of expr * binOp * expr
  | Apply of string * expr
  | Let of string * expr * expr
  | Putchar of expr

let rec find ?(o=0) v = function
  | [] ->
    eprintf "Unknown variable '%s'\n" v;
    failwith "Unknown variable"
  | v'::env ->
    if v = v' then o else find ~o:(o+4) v env

let push env vrs =
  printf "    push    {r%s}\n" (String.concat ", r" (List.map (fun (_, r) -> string_of_int r) vrs));
  List.fold_right (fun (v, r) env -> v::env) vrs env

let pop env rs =
  printf "    pop     {r%s}\n" (String.concat ", r" (List.map string_of_int rs));
  List.skip (List.length rs) env

let rec emit_expr env = function
  | Int n ->
    printf "    movw    r11, %d\n" (n land 0xffff);
    printf "    movt    r11, %d\n" ((n lsr 16) land 0xffff);
    push env ["", 11]
  | Var v ->
    let offset = find v env in
    printf "    ldr     r11, [sp, #%d]\n" offset;
    push env [v, 11]
  | BinOp(f, op, g) ->
    let env = emit_expr env f in
    let env = emit_expr env g in
    let env = pop env [10; 11] in
    let op =
      match op with
      | Add -> "add "
      | Sub -> "sub "
      | Mul -> "mul "
      | Div -> "sdiv" in
    printf "    %s    r11, r11, r10\n" op;
    push env ["", 11]
  | Apply(f, x) ->
    let env = emit_expr env x in
    printf "    bl      %s\n" f;
    env
  | Let(x, body, rest) ->
    let env = emit_expr env body in
    let env = emit_expr (x::env) rest in
    pop env [11]
  | Putchar f ->
    let _ = emit_expr env f in
    printf "    pop     {r0}\n";
    printf "    push    {r0, r1, r2, r7}\n";
    printf "    mov     r0, #0\n";
    printf "    mov     r1, sp\n";
    printf "    mov     r2, #1\n";
    printf "    mov     r7, #4\n";
    printf "    svc     0\n";
    printf "    pop     {r0, r1, r2, r7}\n";
    env

let emit_fn name body =
  printf "%s:\n" name;
  let _ = emit_expr [] body in
  printf "\n"

let () =
  let n =
    match Sys.argv with
    | [|_; n|] -> int_of_string n
    | _ -> 42 in
  printf "    .global main\n";
  printf "main:\n";
  let env = emit_expr [] (Apply("fn", Int n)) in
  printf "    mov     r7, #1\n";
  printf "    svc     0\n";
  emit_fn "fn" (Putchar(Let("c", Let("a", Int n, BinOp(Var "a", Add, Var "a")), Let("b", BinOp(Var "c", Sub, Int n), Var "b"))));
  eprintf "Stack = %s\n" (String.concat ", " env);
  ()
