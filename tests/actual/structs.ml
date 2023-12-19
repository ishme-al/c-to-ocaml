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

type myStructure = { a : int; b : int; c : char; d : float }

let transformAB (str : myStructure) : int =
  let c : int = Int.( * ) str.a str.b in
  let b : int = Int.( + ) str.a str.b in
  Int.( + ) b c

let addAb (str : myStructure) : int = Int.( + ) str.a str.b
let multAb (str : myStructure) : int = Int.( * ) str.a str.b
let subAb (str : myStructure) : int = Int.( - ) str.a str.b
let divideAb (str : myStructure) : int = Int.( / ) str.a str.b

let () =
  let str : myStructure = { a = 1; b = 2; c = 'a'; d = 3. } in
  let a : int = transformAB str in
  let b : int = addAb str in
  let c : int = multAb str in
  let d : int = subAb str in
  let e : int = divideAb str in
  printf "a: %d\n" a;
  printf "b: %d\n" b;
  printf "c: %d\n" c;
  printf "d: %d\n" d;
  printf "e: %d\n" e;
  exit 0
