open Core
module VarMap : Map_intf.S

module Scope : sig
  (* data type represents: 
     string : running transpiled code 
     string VarMap.t : maps all variables in scope (name: type)
     (string * string) list VarMap.t: maps all structs to a list of their (name, type) pairs*)
  type t = string * string VarMap.t * (string * string) list VarMap.t

  (* initializes an empty scope *)
  val empty : t

  (* combines two scopes *)
  val aggregate : t -> t -> t

  (* adds to string of running transpiled code *)
  val add_string : string -> t -> t

  (* adds a new variable to the scope *)
  val add_var : string -> string -> t -> t

  (* adds a new struct type to scope *)
  val add_type : string -> string * string -> t -> t

  (* retrieves string of transpiled code *)
  val get_string : t -> string

  (* retrieves all variables in scope *)
  val get_vars : t -> string VarMap.t

  (* retrieves all structs in scope *)
  val get_types : t -> (string * string) list VarMap.t

  (* retrieves the list of fields of a single struct
     Some if the struct exists
      None if does not exist *)
  val get_type :
    (string * string) list VarMap.t -> string -> (string * string) list option

  (* retrieves the type of a single variable by name *)
  val get_var : string VarMap.t -> string -> string

  (* executes a function and adds the returned scope *)
  val extend :
    f:(string VarMap.t -> (string * string) list VarMap.t -> t) -> t -> t

  (* executes a function of a higher scope 
     (used with if statements, for/while loops, and function declarations)*)
  val new_level :
    f:(string VarMap.t -> (string * string) list VarMap.t -> t) -> t -> t
end
