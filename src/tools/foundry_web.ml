open Unicode.Std

type result =
  | Output      of string
  | Diagnostics of Diagnostic.t list
  | Error       of string

let process code ~do_eval =
  Location.reset ();

  let lexbuf   = Ulexing.from_utf8_string code in
  let lexstate = Lexer.create (Location.register (u"input") 1
                               (Unicode.adopt_utf8s code)) in
  let lex ()   = Lexer.next lexstate lexbuf in
  let parse    = MenhirLib.Convert.Simplified.traditional2revised Parser.toplevel in

  try
    let ast = parse lex in
      match Verifier.check ast with
      | [] ->
        if do_eval then begin
          Rt.roots := Rt.create_roots ();
          let capsule = Ssa.create_capsule () in
            (* let env     = Vm.env_create () in
            let result  = Vm.eval env ast  in
            let Rt.Lambda lam = result in
            Output (Rt.inspect result)
            let func    = Ssa_gen.name_of_lambda lam in
            Ssa.add_func capsule func; *)
            Output (IrPrinter.string_of !Rt.roots capsule)

        end else
          Output (u"")
      | problems ->
        Diagnostics problems
  with
  | Lexer.Unexpected (loc, chr) ->
    Diagnostics [ Diagnostic.Fatal,
                  u"Unexpected character " ^ (Char.escaped chr) ^
                  u" (" ^ (String.make 1 chr) ^ u")", [loc]]
  | Parser.StateError (token, state) ->
    (match token with
    | Parser_tokens.EOF _ when not do_eval
    -> Output (u"")
    | _
    -> Diagnostics [ Diagnostic.Error,
                     Unicode.assert_utf8s (Parser_errors.message state token),
                     [Parser_desc.loc_of_token token] ])
  | Rt.Exc exc ->
    Diagnostics [ Diagnostic.Error, exc.Rt.ex_message, exc.Rt.ex_locations ]
  | Failure msg ->
    Error (Unicode.assert_utf8s msg)

let js_eval input do_eval =
  let inject = Js.Unsafe.inject
  in
  let js_string str =
    Js.string (Unicode.string_of_utf8s str)
  in
  let array f lst =
    Array.of_list (List.map f lst)
  in
  let return ty value =
    Js.Unsafe.obj [|
      ("type",  inject (Js.string ty));
      ("value", inject value)
    |]
  in
  let input   = Js.to_string input in
  let do_eval = Js.to_bool do_eval in
    match process input ~do_eval with
    | Output value
    -> return "output" (js_string value)

    | Diagnostics lst
    -> (let js_of_loc loc =
          let f, p1, p2 = Location.unpack loc in
            Js.Unsafe.obj [|
              ("file", inject (js_string f));
              ("from", inject p1);
              ("to",   inject p2)
            |]
        in let diags =
          Js.array (array
            (fun (severity, message, locations) ->
              let severity  = Diagnostic.string_of_severity severity in
              let message   = js_string message in
              let locations = Js.array (array js_of_loc locations) in
                Js.Unsafe.obj [|
                  ("severity",  inject severity);
                  ("message",   inject message);
                  ("locations", inject locations)
                |])
            lst)
        in return "diagnostics" diags)

    | Error desc
    -> return "error" (js_string desc)

let _ =
  (Js.Unsafe.coerce Dom_html.window)##foundryProcess <- Js.wrap_callback js_eval
