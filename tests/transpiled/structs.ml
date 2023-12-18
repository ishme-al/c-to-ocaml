[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]

open Core

type myStructure = { a : int; b : int; c : char; d : float }

let transformAB (str : myStructure) : int =
  let c : int = Int.( * ) str.a str.b in
  let b : int = Int.( + ) str.a str.b in
  Int.( + ) b c

let addAb (str : myStructure) : int = Int.( + ) str.a str.b
let multAb (str : myStructure) : int = Int.( * ) str.a str.b
let subAb (str : myStructure) : int = Int.( - ) str.a str.b
let divideAb (str : myStructure) : int = Int.( / ) str.a str.b
