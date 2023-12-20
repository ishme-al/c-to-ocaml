[@@@warning "-26"]
[@@@warning "-27"]
[@@@warning "-32"]
[@@@warning "-69"]

open Core

let rec set_at_index (lst : 'a list) (index : int) (value : 'a) : 'a list =
  match lst with
  | [] -> failwith "Index out of bounds"
  | hd :: tl ->
      if index = 0 then value :: tl else hd :: set_at_index tl (index - 1) value

type myStruct = { a : int; b : int; c : float; d : char }

let () =
  let str : myStruct = { a = 1; b = 2; c = 3.; d = 'a' } in
  let a : int = str.a in
  let b : int = str.b in
  let m : int = Int.( + ) str.a str.b in
  let d : char = str.d in
  let d = 'a' in
  exit 0
