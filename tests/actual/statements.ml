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

let () =
  let x : int = 2 in
  let y : int = 3 in
  let z : int = 4 in
  let z = z + 1 in
  let a : int = Int.( + ) x y in
  let b : int = Int.( - ) z y in
  let c : int = Int.( * ) z y in
  let d : int = Int.( / ) z y in
  let e : float = 13. in
  exit 0
