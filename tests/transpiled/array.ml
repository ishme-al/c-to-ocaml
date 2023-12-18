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
  let b : float list = [ 2.; 2.3; 3.1 ] in
  let a : float list = create_empty_float_list 3 in
  let c : float list = create_empty_float_list 3 in
  exit 0
