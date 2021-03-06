(*
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
  | vs::env ->
    if List.exists ((=) v) vs then o else find ~o:(o+4) v env

let push env rs =
  printf "    push    {r%s}\n" (String.concat ", r" (List.map (fun r -> string_of_int r) rs));
  List.fold_right (fun _ env -> []::env) rs env

let pop env rs =
  printf "    pop     {r%s}\n" (String.concat ", r" (List.map string_of_int rs));
  List.skip (List.length rs) env

let mk f =
  let n = ref 0 in
  fun () ->
    incr n;
    f !n

let mk_lbl = mk (sprintf ".L%d")
let mk_arg = mk (sprintf "arg%d")
let lr = 14

let name_top env v =
  match env with
  | vs::env -> (v::vs)::env
  | [] -> failwith "Attempt to name top of empty stack"

let emit_lbl lbl =
  printf "%s:\n" lbl

let emit_int n r =
  let n = Int32.of_int n in
  printf "    movw    r%d, %ld\n" r (Int32.logand n 0xffffl);
  printf "    movt    r%d, %ld\n" r (Int32.logand (Int32.shift_right_logical n 16) 0xffffl)

let emit_var env v r =
  let offset = find v env in
  printf "    ldr     r%d, [sp, #%d]\n" r offset

let rec emit_patt env arg patt fail_lbl =
  match patt with
  | PAny -> env
  | PInt n ->
    emit_var env arg 10;
    emit_int n 11;
    printf "    cmp     r10, r11\n";
    printf "    bne     %s\n" fail_lbl;
    env
  | PVar v -> name_top env v
  | POr(p1, p2) ->
    let pass_lbl = mk_lbl() in
    let next_lbl = mk_lbl() in
    let env = emit_patt env arg p1 next_lbl in
    printf "    b       %s\n" pass_lbl;
    emit_lbl next_lbl;
    let env = emit_patt env arg p2 fail_lbl in
    emit_lbl pass_lbl;
    env
and emit_expr env = function
  | Int n ->
    emit_int n 11;
    push env [11]
  | Var v ->
    emit_var env v 11;
    name_top (push env [11]) v
  | BinOp(f, op, g) ->
    let env = emit_expr env f in
    let env = emit_expr env g in
    let env = pop env [10; 11] in
    printf "    %s    r11, r11, r10\n" (string_of_op op);
    push env [11]
  | Apply(f, x) ->
    let env = emit_expr env f in
    let env = emit_expr env x in
    let env = pop env [10; 11] in
    let env = push env [10] in
    printf "    blx     r11\n";
    env
  | Match(arg, cases) ->
    (* Push arg *)
    let env = emit_expr env arg in
    (* Name top of stack *)
    let arg = mk_arg() in
    emit_cases (name_top env arg) arg cases (mk_lbl())
  | Fun(x, f) ->
    let fn_lbl = mk_lbl() in
    let after_lbl = mk_lbl() in
    printf "    b       %s\n" after_lbl;
    emit_lbl fn_lbl;
    printf "    push    {lr}\n";
    let env2 = emit_expr [[]; [x]] f in
    let env2 = pop env2 [9; 10; 11] in
    let _ = push env2 [9] in
    printf "    bx      r10\n";
    emit_lbl after_lbl;
    printf "    ldr     r11, =%s\n" fn_lbl;
    push env [11]
  | Let(f, Fun(x, body), rest) ->
    let fn_lbl = mk_lbl() in
    let after_lbl = mk_lbl() in
    printf "    b       %s\n" after_lbl;
    emit_lbl fn_lbl;
    printf "    ldr     r11, =%s\n" fn_lbl;
    let env2 = push [[x]] [11; lr] in
    let env2 = name_top env2 f in
    let env2 = emit_expr env2 body in
    let env2 = pop env2 [8; 9; 10; 11] in
    let _ = push env2 [8] in
    printf "    bx      r10\n";
    emit_lbl after_lbl;
    printf "    ldr     r11, =%s\n" fn_lbl;
    let env = push env [11] in
    let env = emit_expr (name_top env f) rest in
    let env = pop env [10; 11] in
    push env [10]
  | Let(x, body, rest) ->
    let env = emit_expr env body in
    let env = emit_expr (name_top env x) rest in
    let env = pop env [10; 11] in
    push env [10]
and emit_cases env arg cases final_lbl =
  match cases with
  | [] ->
    emit_lbl final_lbl;
    (* Pop ret and arg off the stack and push ret back on. *)
    let env = pop ([]::env) [10; 11] in
    push env [10]
  | (patt, expr)::cases ->
    let fail_lbl = mk_lbl() in
    let env2 = emit_patt env arg patt fail_lbl in
(*
    eprintf "%s\n" (String.concat "; " (List.map (String.concat ", ") env2));
*)
    let _ = emit_expr env2 expr in
    printf "    b       %s\n" final_lbl;
    emit_lbl fail_lbl;
    emit_cases env arg cases final_lbl

let () =
  Printexc.record_backtrace true;
  eprintf "Give me an expression in ML syntax like \"let f = fun n -> match n with 0 | 1 -> n | n -> f(n-2)+f(n-1) in f 10\"\n> %!";
  let line = read_line() in
  let lexbuf = Lexing.from_string line in
  try
    let expr = Parser.program Lexer.token lexbuf in
    eprintf "Generating Arm assembly for %s\n" (string_of_expr () expr);
    printf "    .global _start\n";
    printf "_start:\n";
    let _ = emit_expr [] expr in
    printf "    pop     {r0}\n";
    printf "    mov     r7, #1\n";
    printf "    svc     0\n"
  with
  | e ->
    eprintf "Exception: %s\n%s\n%!" (Printexc.to_string e) (Printexc.get_backtrace());
    let curr = lexbuf.Lexing.lex_curr_p in
    let line = curr.Lexing.pos_lnum in
    let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
    eprintf "At line %d column %d\n" line cnum
