[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]

open Core

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
