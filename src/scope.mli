open Core
module VarMap : Map_intf.S

module Scope : sig
  type t = string * string VarMap.t * (string * string) list VarMap.t

  val empty : t
  val aggregate : t -> t -> t
  val add_string : string -> t -> t
  val add_var : string -> string -> t -> t
  val add_type : string -> string * string -> t -> t
  val get_string : t -> string
  val get_vars : t -> string VarMap.t
  val get_types : t -> (string * string) list VarMap.t

  val get_type :
    (string * string) list VarMap.t -> string -> (string * string) list option

  val get_var : string VarMap.t -> string -> string

  val extend :
    f:(string VarMap.t -> (string * string) list VarMap.t -> t) -> t -> t

  val new_level :
    f:(string VarMap.t -> (string * string) list VarMap.t -> t) -> t -> t
end
