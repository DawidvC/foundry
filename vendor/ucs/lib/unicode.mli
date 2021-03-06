(* Single encoded code points. *)
type utf8
type utf16
type utf32 = private int

(* Encoded unicode strings *)
type utf8s = private string
type utf16s = private int list
type utf32s = private int list

(* The number of trailing octets *)
val utf8_length : char -> int

(* Validate representation *)
val adopt_utf32 : int -> utf32

val adopt_utf8s : string -> utf8s
val adopt_utf16s : int list -> utf16s
val adopt_utf32s : int list -> utf32s

(* Import without validation. Use with care! *)
val assert_utf8s : string -> utf8s

(* List of characters to string *)
val utf8s_of_list : utf8 list -> utf8s
val utf16s_of_list : utf16 list -> utf16s
val utf32s_of_list : utf32 list -> utf32s

(* String to list of characters *)
val list_of_utf8s : utf8s -> utf8 list
val list_of_utf16s : utf16s -> utf16 list
val list_of_utf32s : utf32s -> utf32 list

(* Single UTF-8 of single UTF-16/32 *)
val utf8_of_utf16 : utf16 -> utf8
val utf8_of_utf32 : utf32 -> utf8

(* Single UTF-8 of UTF-8/16/32 string containing one character *)
val utf8_of_utf8s : utf8s -> utf8
val utf8_of_utf16s : utf16s -> utf8
val utf8_of_utf32s : utf32s -> utf8

(* UTF-8 string of single UTF-8/16/32 *)
val utf8s_of_utf8 : utf8 -> utf8s
val utf8s_of_utf16 : utf16 -> utf8s
val utf8s_of_utf32 : utf32 -> utf8s

(* UTF-8 string of UTF-16/32 string containing one character *)
val utf8s_of_utf16s : utf16s -> utf8s
val utf8s_of_utf32s : utf32s -> utf8s


(* Single UTF-16 of single UTF-8/32 *)
val utf16_of_utf8 : utf8 -> utf16
val utf16_of_utf32 : utf32 -> utf16

(* Single UTF-16 of UTF-8/16/32 string containing one character *)
val utf16_of_utf8s : utf8s -> utf16
val utf16_of_utf16s : utf16s -> utf16
val utf16_of_utf32s : utf32s -> utf16

(* UTF-16 string of single UTF-8/16/32 *)
val utf16s_of_utf8 : utf8 -> utf16s
val utf16s_of_utf16 : utf16 -> utf16s
val utf16s_of_utf32 : utf32 -> utf16s

(* UTF-16 string of UTF-8/32 string containing one character *)
val utf16s_of_utf8s : utf8s -> utf16s
val utf16s_of_utf32s : utf32s -> utf16s


(* Single UTF-32 of single UTF-8/16 *)
val utf32_of_utf8 : utf8 -> utf32
val utf32_of_utf16 : utf16 -> utf32

(* Single UTF-32 of UTF-8/16/32 string containing one character *)
val utf32_of_utf8s : utf8s -> utf32
val utf32_of_utf16s : utf16s -> utf32
val utf32_of_utf32s : utf32s -> utf32

(* UTF-32 string of single UTF-8/16/32 *)
val utf32s_of_utf8 : utf8 -> utf32s
val utf32s_of_utf16 : utf16 -> utf32s
val utf32s_of_utf32 : utf32 -> utf32s

(* UTF-32 string of UTF-8/16 string containing one character *)
val utf32s_of_utf8s : utf8s -> utf32s
val utf32s_of_utf16s : utf16s -> utf32s


(* Conversion to OCaml string *)
val string_of_utf8   : utf8   -> string
val string_of_utf8s  : utf8s  -> string
val string_of_utf16  : utf16  -> string
val string_of_utf16s : utf16s -> string
val string_of_utf32  : utf32  -> string
val string_of_utf32s : utf32s -> string


(* Show the numbers making up the internal representation
 * like [f0; 91; 82; a3] for utf8 and [d804; dca3] for utf16. *)
val xstring_of_utf8   : utf8   -> string
val xstring_of_utf8s  : utf8s  -> string
val xstring_of_utf16  : utf16  -> string
val xstring_of_utf16s : utf16s -> string
val xstring_of_utf32  : utf32  -> string
val xstring_of_utf32s : utf32s -> string

(* A standard library overlay *)

module Std : sig
  type latin1c = char
  type char    = utf32

  val char_of_int      : int -> char
  val int_of_char      : char -> int

  type latin1s = string
  type string  = utf8s

  val u : latin1s -> utf8s

  val string_of_bool   : bool -> string
  val bool_of_string   : string -> bool

  val string_of_int    : int -> string
  val int_of_string    : string -> int

  val string_of_float  : float -> string
  val float_of_string  : string -> float

  val string_of_sexp   : Sexplib.Sexp.t -> string
  val sexp_of_string   : string -> Sexplib.Sexp.t

  val (^) : string -> string -> string

  val print_string  : string -> unit
  val print_endline : string -> unit

  val prerr_string  : string -> unit
  val prerr_endline : string -> unit

  val output_char   : out_channel -> char -> unit
  val output_string : out_channel -> string -> unit

  val invalid_arg   : string -> 'a
  val failwith      : string -> 'a

  module Char : sig
    val of_string : string -> char

    val chr     : int -> char
    val code    : char -> int

    val escaped : char -> utf8s
  end

  module ByteArray : module type of ExtString.String

  module String : sig
    val of_char : char -> string

    val length : string -> int

    val get    : string -> int -> char
    val set    : string -> int -> char -> unit

    val make   : int -> char -> string
    val concat : string -> string list -> string

    val sub        : string -> int -> int -> string
    val index_from : string -> int -> char -> int
  end

  module Big_int : sig
    type big_int = Fy_big_int.big_int

    include module type of Fy_big_int with type big_int := big_int

    val string_of_big_int : big_int -> string
    val big_int_of_string : string -> big_int

    val big_int_of_sexp   : Sexplib.Sexp.t -> big_int
    val sexp_of_big_int   : big_int -> Sexplib.Sexp.t
  end
end
