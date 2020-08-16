(*
Supports named variables.

Any intermediate value can be named and referred back to via
the stack.
*)

open Printf
open Ast

module List = struct
  include List

  let rec skip n xs =
    match n, xs with
    | 0, xs -> xs
    | _, [] -> failwith "List.skip <n> []"
    | n, _::xs -> skip (n-1) xs
end

let rec find ?(o=0) v = function
  | [] ->
    eprintf "Unknown variable '%s'\n" v;
    failwith "Unknown variable"
  | v'::env ->
    if v = v' then o else find ~o:(o+4) v env

let push env vrs =
  printf "    push    {r%s}\n" (String.concat ", r" (List.map (fun (_, r) -> string_of_int r) vrs));
  List.fold_right (fun (v, _) env -> v::env) vrs env

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
    printf "    %s    r11, r11, r10\n" (string_of_op op);
    push env ["", 11]
  | Let(x, body, rest) ->
    let _::env | env = emit_expr env body in
    let env = emit_expr (x::env) rest in
    let env = pop env [10; 11] in
    push env ["", 10]

let () =
  eprintf "Give me an expression in ML syntax like \"let x = 3 in x*(x+1)\"\n> %!";
  let expr =
    read_line()
    |> Lexing.from_string
    |> Parser.program Lexer.token in
  eprintf "Generating Arm assembly for %s\n" (string_of_expr () expr);
   printf "    .global _start\n";
  printf "_start:\n";
  let _ = emit_expr [] expr in
  printf "    pop     {r0}\n";
  printf "    mov     r7, #1\n";
  printf "    svc     0\n"
