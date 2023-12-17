open Core

module VarMap = Map.Make (String)

module Scope = struct

  type t = string * string VarMap.t

  let empty : t = ("", VarMap.empty)
  let create (str : string) (map : string VarMap.t) : t = (str, map)

  let aggregate (scope1 : t) (scope2 : t) : t =
    let str, _ = scope1 in
    let str', map' = scope2 in
    (str ^ str', map')

  let add_string (s : string) (scope : t) : t =
    let str, map = scope in
    (str ^ s, map)

  let add_var (name : string) (s : string) (scope : t) : t =
    let str, map = scope in
    let map' = Map.update map name ~f:(fun _ -> s) in
    (str, map')

  let get_string (scope : t) : string =
    let str, _ = scope in
    str

  let get_vars (scope : t) : string VarMap.t =
    let _, map = scope in
    map

  let get_var (map : string VarMap.t) (name : string) : string =
    Map.find_exn map name

  let extend ~(f : string VarMap.t -> t) (scope : t) : t =
    f @@ get_vars scope |> aggregate scope
end