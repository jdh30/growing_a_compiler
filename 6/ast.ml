open Printf

type binOp = Add | Sub | Mul | Div | And | Or | Eor | Bic

type patt =
  | PAny
  | PInt of int
  | PVar of string
  | POr of patt * patt

type expr =
  | Int of int
  | Var of string
  | BinOp of expr * binOp * expr
  | Match of expr * (patt * expr) list
  | Apply of expr * expr
  | Fun of string * expr
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

let rec string_of_patt () = function
  | PAny -> "_"
  | PInt n -> string_of_int n
  | PVar v -> v
  | POr(p1, p2) -> sprintf "%a | %a" string_of_patt p1 string_of_patt p2
and string_of_expr () = function
  | Int n -> string_of_int n
  | Var v -> v
  | BinOp(f, op, g) ->
    sprintf "%s(%a, %a)" (string_of_op op) string_of_expr f string_of_expr g
  | Match(arg, cases) ->
    sprintf "(match %a with %s)" string_of_expr arg
      (String.concat " | " (List.map string_of_case cases))
  | Apply(f, x) -> sprintf "(%a)(%a)" string_of_expr f string_of_expr x
  | Fun(x, f) -> sprintf "(fun %s -> %a)" x string_of_expr f
  | Let(x, body, rest) ->
    sprintf "let %s = %a in %a" x string_of_expr body string_of_expr rest
and string_of_case (patt, expr) =
  sprintf "%a -> %a" string_of_patt patt string_of_expr expr
