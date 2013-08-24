{
  open Fy_big_int
  open IrParser_tokens
}

let name = ['A'-'Z' 'a'-'z' '0'-'9' '_' ':' '.']+

rule lex = parse
| [' ' '\t' '\n'] { lex lexbuf }
| ';' [^'\n']*    { lex lexbuf }

| '%' (name as n)            { Name_Local  (Unicode.adopt_utf8s n) }
| '%' '"' ([^'"']+ as n) '"' { Name_Local  (Unicode.adopt_utf8s n) }
| '@' (name as n)            { Name_Global (Unicode.adopt_utf8s n) }
| '@' '"' ([^'"']+ as n) '"' { Name_Global (Unicode.adopt_utf8s n) }
| (name as n) ':'            { Name_Label  (Unicode.adopt_utf8s n) }
| '"' ([^'"']+ as n) '"' ':' { Name_Label  (Unicode.adopt_utf8s n) }

| '"' ([^'"']+ as s) '"' { Lit_String  (Unicode.adopt_utf8s s) }
| ['0'-'9']+ as d        { Lit_Integer (big_int_of_string d) }

| '('  { LParen }
| ')'  { RParen }
| '['  { LBrack }
| ']'  { RBrack }
| '{'  { LBrace }
| '}'  { RBrace }
| ','  { Comma }
| '='  { Equal }
| "->" { Arrow }
| "=>" { FatArrow }

| "type"          { Type }
| "tvar"          { Tvar }
| "nil"           { Nil }
| "true"          { True }
| "false"         { False }
| "boolean"       { Boolean }
| "int"           { Int }
| "unsigned"      { Unsigned }
| "signed"        { Signed }
| "symbol"        { Symbol }
| "environment"   { Environment }
| "lambda"        { Lambda }
| "closure"       { Closure }
| "class"         { Class }
| "mixin"         { Mixin }
| "package"       { Package }
| "instance"      { Instance }

| "immutable"     { Immutable }
| "mutable"       { Mutable }
| "meta_mutable"  { Meta_mutable }
| "dynamic"       { Dynamic }

| "parent"        { Parent }
| "bindings"      { Bindings }

| "local_env"     { Local_env }
| "type_env"      { Type_env }
| "const_env"     { Const_env }

| "metaclass"     { Metaclass }
| "ancestor"      { Ancestor }
| "parameters"    { Parameters }
| "slots"         { Slots }
| "methods"       { Methods }
| "prepended"     { Prepended }
| "appended"      { Appended }
| "constants"     { Constants }

| "args"
  { Syntax_Args (Syntax.formal_args_of_sexp (Sexplib.Sexp.scan_sexp lexbuf))  }
| "body"
  { Syntax_Exprs (Syntax.exprs_of_sexp (Sexplib.Sexp.scan_sexp lexbuf)) }

| "code" (([^';']+ ';'?)+ as code) ";;"
  {
    let lexbuf   = Ulexing.from_utf8_string code in
    let lexstate = Lexer.create (Location.register (u"input") 1
                                 (Unicode.adopt_utf8s code)) in
    let lex ()   = Lexer.next lexstate lexbuf in
    let parse    = MenhirLib.Convert.Simplified.traditional2revised Parser.toplevel in

    match parse lex with
    | [Syntax.Lambda _ as lambda] -> Syntax_Lambda lambda
    | _ -> failwith "code: one lambda expected"
  }

| "empty"         { Empty }

| "function"      { Function }
| "jump"          { Jump }
| "jump_if"       { Jump_if }
| "return"        { Return }
| "phi"           { Phi }
| "frame"         { Frame }
| "lvar_load"     { Lvar_load }
| "lvar_store"    { Lvar_store }
| "resolve"       { Resolve }
| "call"          { Call }
| "closure"       { Closure }
| "primitive"     { Primitive }

| "map"           { Map }

| (['a'-'z']+) as kw { failwith ("unknown keyword: " ^ kw) }
| eof                { EOF }

{
  let next lexbuf =
    let token = lex lexbuf in
      token, Lexing.lexeme_start_p lexbuf, Lexing.lexeme_end_p lexbuf
}
