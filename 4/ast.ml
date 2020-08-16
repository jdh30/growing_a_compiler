open Printf

type binOp = Add | Sub | Mul | Div | And | Or | Eor | Bic

type expr =
  | Int of int
  | Var of string
  | BinOp of expr * binOp * expr
  | Let of string * expr * expr

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
  | Var v -> v
  | BinOp(f, op, g) ->
    sprintf "%s(%a, %a)" (string_of_op op) string_of_expr f string_of_expr g
  | Let(x, body, rest) ->
    sprintf "let %s = %a in %a" x string_of_expr body string_of_expr rest
