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

let foo (a : float) (b : float) : float =
  let y, x =
    if Float.( < ) a b then
      let z : float = 2 in
      let x = Float.( - ) b a in
      let y = Float.( + ) z a in
      (y, x)
    else
      let z : float = 3 in
      let x = Float.( - ) a b in
      let y = Float.( + ) z b in
      (y, x)
  in
  Float.( + ) x y

let () =
  let x : float = foo (foo 4 6) 3 in
  exit 0
