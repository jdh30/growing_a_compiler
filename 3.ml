(*
Simple stack-based compiler

This compiler generates stack-based code and supports ints,
addition and putchar. Stack-based code is simple but very
inefficient on Arm because it doesn't exploit the availability
of 15 general purpose registers.
*)

open Printf

type binOp = Add | Sub | Mul | Div | And | Or | Eor | Bic

type expr =
  | Int of int
  | BinOp of expr * binOp * expr

let string_of_op = function
  | Add -> "add "
  | Sub -> "sub "
  | Mul -> "mul "
  | Div -> "sdiv"
  | And -> "and "
  | Or -> "orr "
  | Eor -> "eor "
  | Bic -> "bic "

let rec string_of_expr () = function
  | Int n -> string_of_int n
  | BinOp(f, op, g) ->
    sprintf "%s(%a, %a)" (string_of_op op) string_of_expr f string_of_expr g

let rec emit_expr = function
  | Int n ->
    printf "    movw    r11, %d\n" (n land 0xffff);
    printf "    movt    r11, %d\n" ((n lsr 16) land 0xffff);
    printf "    push    {r11}\n"
  | BinOp(f, op, g) ->
    emit_expr f;
    emit_expr g;
    printf "    pop     {r10, r11}\n";
    printf "    %s    r11, r11, r10\n" (string_of_op op);
    printf "    push    {r11}\n"

let lex tokens word =
  if String.length word = 0 then tokens else
    (try `Int(int_of_string word) with _ -> `Op word)::tokens

let op_of = function
  | "+" -> Add
  | "-" -> Sub
  | "*" -> Mul
  | "/" -> Div
  | "&&" -> And
  | "||" -> Or
  | "^^" -> Eor
  | "bic" -> Bic
  | _ -> failwith "Unknown operator"

let rec parse stack words =
  match stack, words with
  | [f], [] -> f
  | stack, `Int n::words -> parse (Int n::stack) words
  | g::f::stack, `Op op::words -> parse (BinOp(f, op_of op, g)::stack) words
  | _ -> failwith "Parse error"

let () =
  eprintf "Give me an expression in reverse Polish notation like 2 3 + 4 * 5 /:\n> %!";
  let expr =
    read_line()
    |> String.split_on_char ' '
    |> List.fold_left lex []
    |> List.rev
    |> parse [] in
  eprintf "Generating Arm assembly for %s\n" (string_of_expr () expr);
  printf "    .global _start\n";
  printf "_start:\n";
  emit_expr expr;
  printf "    pop     {r0}\n";
  printf "    mov     r7, #1\n";
  printf "    svc     0\n"
