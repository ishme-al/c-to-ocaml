[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]
[@@@ocaml.warning "-32"]
[@@@ocaml.warning "-69"]

open Core

let rec set_at_index (lst : 'a list) (index : int) (value : 'a) : 'a list =
  match lst with
  | [] -> failwith "Index out of bounds"
  | hd :: tl ->
      if index = 0 then value :: tl else hd :: set_at_index tl (index - 1) value

let test1 (a : int) (b : int) : int = Int.( + ) a b
let test2 (a : int) (b : char) : int = a

let test3 (a : int) (b : char) : char =
  let a = Int.( * ) a 2 in
  let a = Int.( + ) a 3 in
  b
