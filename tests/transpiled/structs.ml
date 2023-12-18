[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]

open Core

let rec set_at_index (lst : 'a list) (index : int) (value : 'a) : 'a list =
  match lst with
  | [] -> failwith "Index out of bounds"
  | hd :: tl ->
      if index = 0 then value :: tl else hd :: set_at_index tl (index - 1) value

let create_empty_string_list n =
  let rec aux acc remaining =
    if remaining = 0 then acc else aux ("" :: acc) (remaining - 1)
  in
  aux [] n

let create_empty_char_list n =
  let rec aux acc remaining =
    if remaining = 0 then acc else aux (' ' :: acc) (remaining - 1)
  in
  aux [] n

let create_empty_int_list n =
  let rec aux acc remaining =
    if remaining = 0 then acc else aux (0 :: acc) (remaining - 1)
  in
  aux [] n

let create_empty_float_list n =
  let rec aux acc remaining =
    if remaining = 0 then acc else aux (0.0 :: acc) (remaining - 1)
  in
  aux [] n

type myStructure = { a : int; b : int; c : char; d : float }

let transformAB (str : myStructure) : int =
  let c : int = Int.( * ) str.a str.b in
  let b : int = Int.( + ) str.a str.b in
  Int.( + ) b c

let addAb (str : myStructure) : int = Int.( + ) str.a str.b
let multAb (str : myStructure) : int = Int.( * ) str.a str.b
let subAb (str : myStructure) : int = Int.( - ) str.a str.b
let divideAb (str : myStructure) : int = Int.( / ) str.a str.b
