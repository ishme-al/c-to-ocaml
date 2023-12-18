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

let () =
  let x : int = 0 in
  let y : int = 0 in
  let y, x =
    if Int.( > ) x y then
      let x = Int.( + ) x 1 in
      (y, x)
    else
      let y = Int.( + ) y 1 in
      (y, x)
  in
  let x =
    if Int.( = ) x 0 then
      let x = y in
      x
    else x
  in
  let x =
    if Int.( = ) x y then
      let x = Int.( + ) x y in
      x
    else x
  in
  exit 0
