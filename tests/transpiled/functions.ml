[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]

open Core

let test1 (a : int) (b : int) : int = Int.( + ) a b
let test2 (a : int) (b : char) : int = a

let test3 (a : int) (b : char) : char =
  let a = Int.( * ) a 2 in
  let a = Int.( + ) a 3 in
  b
