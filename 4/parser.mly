%{
open Ast
%}

%token <int> INT
%token <string> LIDENT
%token LET IN AMPAMP PIPEPIPE EQUAL PLUS MINUS ASTERISK SLASH
%token LPAREN RPAREN
%token EOF

%left PIPEPIPE
%left AMPAMP
%left PLUS MINUS
%left ASTERISK SLASH

%start <expr> program

%%

program:
| e = expr EOF                   { e }

expr:
| i = INT                        { Int i }
| v = LIDENT                     { Var v }
| LPAREN e = expr RPAREN         { e }
| e1 = expr AMPAMP e2 = expr     { BinOp(e1, And, e2) }
| e1 = expr PIPEPIPE e2 = expr   { BinOp(e1, Or, e2) }
| e1 = expr PLUS e2 = expr       { BinOp(e1, Add, e2) }
| e1 = expr MINUS e2 = expr      { BinOp(e1, Sub, e2) }
| e1 = expr ASTERISK e2 = expr   { BinOp(e1, Mul, e2) }
| e1 = expr SLASH e2 = expr      { BinOp(e1, Div, e2) }
| LET x = LIDENT EQUAL f = expr IN g = expr  { Let(x, f, g) }
