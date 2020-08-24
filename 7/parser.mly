%{
open Ast
%}

%token <int> INT
%token <string> LIDENT
%token LET IN FUN ARROW MATCH WITH PIPE UNDERSCORE
%token AMPAMP PIPEPIPE EQUAL PLUS MINUS ASTERISK SLASH
%token LPAREN RPAREN
%token EOF

%left IN
%left PIPEPIPE
%left AMPAMP
%left PLUS MINUS
%left ASTERISK SLASH
%nonassoc UMINUS
%left APPLY
%left LPAREN

%start <expr> program

%%

program:
| e = expr EOF                        { e }

patt:
| UNDERSCORE                          { PAny }
| i=INT                               { PInt i }
| MINUS n=INT %prec UMINUS            { PInt(-n) }
| v=LIDENT                            { PVar v }
| p1=patt PIPE p2=patt                { POr(p1, p2) }

expr:
| non_app             { $1 }
| app                 { $1 }
| MINUS e=expr %prec UMINUS           { BinOp(Int 0, Sub, e) }
| e1=expr AMPAMP e2=expr       { BinOp(e1, And, e2) }
| e1=expr PIPEPIPE e2=expr     { BinOp(e1, Or, e2) }
| e1=expr PLUS e2=expr         { BinOp(e1, Add, e2) }
| e1=expr MINUS e2=expr        { BinOp(e1, Sub, e2) }
| e1=expr ASTERISK e2=expr     { BinOp(e1, Mul, e2) }
| e1=expr SLASH e2=expr        { BinOp(e1, Div, e2) }
| MATCH arg=expr WITH cases=cases     { Match(arg, cases) }
| FUN x=LIDENT ARROW f=expr           { Fun(x, f) }
| LET x=LIDENT EQUAL f=expr IN g=expr { Let(x, f, g) }

app:
| f=app x=non_app         { Apply (f, x) }
| f=non_app x=non_app     { Apply (f, x) }

non_app:
| i=INT                               { Int i }
| v=LIDENT                            { Var v }
| LPAREN e=expr RPAREN                { e }

case:
| patt=patt ARROW expr=expr           { patt, expr }

cases:
| cases=separated_list(PIPE, case)    { cases }
