open Core

module VarMap = Map.Make (String)

module Scope = struct
  type t = string * string VarMap.t * (string * string) list VarMap.t

  let empty : t = ("[@@@ocaml.warning \"-26\"] \n
  [@@@ocaml.warning \"-27\"]\n
  open Core \n
  let rec set_at_index (lst: 'a list) (index:int) (value: 'a) : 'a list =
    match lst with
    | [] -> failwith \"Index out of bounds\"
    | hd :: tl ->
      if index = 0 then
        value :: tl
      else
        hd :: set_at_index tl (index - 1) value
      let create_empty_string_list n =
        let rec aux acc remaining =
          if remaining = 0 then acc
          else aux (\"\" :: acc) (remaining - 1)
        in
        aux [] n
      let create_empty_char_list n =
        let rec aux acc remaining =
          if remaining = 0 then acc
          else aux ('\000' :: acc) (remaining - 1)
        in
        aux [] n
      let create_empty_int_list n =
        let rec aux acc remaining =
          if remaining = 0 then acc
          else aux (0 :: acc) (remaining - 1)
        in
        aux [] n
      let create_empty_float_list n =
        let rec aux acc remaining =
          if remaining = 0 then acc
          else aux (0.0 :: acc) (remaining - 1)
        in
        aux [] n
        "
                   , 
                   VarMap.empty, VarMap.empty)

  let aggregate (scope1 : t) (scope2 : t) : t =
    let str, _, _ = scope1 in
    let str', var_map', type_map' = scope2 in
    (str ^ str', var_map', type_map')

  let add_string (s : string) (scope : t) : t =
    let str, var_map, type_map = scope in
    (str ^ s, var_map, type_map)

  let add_var (name : string) (s : string) (scope : t) : t =
    let str, var_map, type_map = scope in
    let var_map' = Map.update var_map name ~f:(fun _ -> s) in
    (str, var_map', type_map)

  let add_type (struct_name : string) (var : string * string) (scope : t) : t =
    let str, var_map, type_map = scope in
    let type_map' = Map.add_multi type_map ~key:struct_name ~data:var in
    (str, var_map, type_map')

  let get_string (scope : t) : string =
    let str, _, _ = scope in
    str

  let get_vars (scope : t) : string VarMap.t =
    let _, map, _ = scope in
    map

  let get_types (scope : t) : (string * string) list VarMap.t =
    let _, _, map = scope in
    map

  let get_type (map : (string * string) list VarMap.t) (name : string) : (string * string) list option =
    Map.find map name

  let get_var (map : string VarMap.t) (name : string) : string =
    Map.find_exn map name

  let extend ~(f : string VarMap.t -> (string * string) list VarMap.t -> t) (scope : t) : t =
    f (get_vars scope) (get_types scope) |> aggregate scope
end