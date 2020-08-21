{
  open Parser

  exception Mistake of char
}

let lident = ['a'-'z']['a'-'z''A'-'Z''0'-'9']*

rule token = parse
| [' ' '\t']         { token lexbuf }
| ['0'-'9']+ as i    { INT (int_of_string i) }
| "let"              { LET }
| "in"               { IN }
| "fun"              { FUN }
| "match"            { MATCH }
| "with"             { WITH }
| lident as v        { LIDENT v }
| "&&"               { AMPAMP}
| "||"               { PIPEPIPE }
| "->"               { ARROW }
| '='                { EQUAL }
| '+'                { PLUS }
| '-'                { MINUS }
| '*'                { ASTERISK }
| '/'                { SLASH }
| '('                { LPAREN }
| ')'                { RPAREN }
| '|'                { PIPE }
| '_'                { UNDERSCORE }
| eof                { EOF }
| _ as c             { raise(Mistake c) }
