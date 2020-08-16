{
  open Parser

  exception Mistake
}

let lident = ['a'-'z']['a'-'z''A'-'Z''0'-'9']*

rule token = parse
| [' ' '\t']         { token lexbuf }
| ['0'-'9']+ as i    { INT (int_of_string i) }
| "let"              { LET }
| "in"               { IN }
| lident as v        { LIDENT v }
| "&&"               { AMPAMP}
| "||"               { PIPEPIPE }
| '='                { EQUAL }
| '+'                { PLUS }
| '-'                { MINUS }
| '*'                { ASTERISK }
| '/'                { SLASH }
| '('                { LPAREN }
| ')'                { RPAREN }
| eof                { EOF }
| _                  { raise Mistake }
