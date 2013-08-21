open Unicode.Std

type 'a t
with sexp_of

val create   : (string * 'a) list -> 'a t
val pair     : string -> 'a -> 'a t
val fill     : 'a t -> (string * 'a) list -> unit
val replace  : 'a t -> 'a t -> unit
val copy     : 'a t -> 'a t

val get      : 'a t -> string -> 'a option
val get_exn  : 'a t -> string -> 'a
val set      : 'a t -> string -> 'a -> unit
val exists   : 'a t -> string -> bool
val empty    : 'a t -> bool

val iter     : ?ordered:bool -> f:(string -> 'a -> unit) -> 'a t -> unit
val map_list : ?ordered:bool -> f:(string -> 'a -> 'b) -> 'a t -> 'b list
val map      : f:('a -> 'b) -> 'a t -> 'b t
val map2     : f:('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
val fold     : f:(string -> 'b -> 'a -> 'b) -> 'b -> 'a t -> 'b
val fold2    : f:(string -> 'c -> 'a -> 'b -> 'c) -> 'c -> 'a t -> 'b t -> 'c
val join     : 'a t -> 'a t -> 'a t

val keys     : 'a t -> string list

val except_keys   : 'a t -> string list -> 'a t

(* equal_keys table other: Checks that table and other have the same set of keys *)
val equal_keys    : 'a t -> 'b t -> bool

(* diff_keys table other: Returns the keys in other which are not present in table *)
val diff_keys     : 'a t -> 'b t -> string list
(* includes_keys table other: Checks that all keys in other are present in table *)
val includes_keys : 'a t -> 'b t -> bool
