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

let notmain : int =
  let x : int = Int.( + ) 1 2 in
  let y : int = 2 in
  let a : int = 0 in
  let b : int = 0 in
  let rec forLoop140 (y, x) (b, a) =
    if Int.( < ) a 10 then (y, x)
    else
      let x = Int.( + ) x 1 in
      let a = Int.( + ) a 1 in
      let y = Int.( + ) x 1 in
      let a = a + 1 in
      forLoop140 (y, x) (b, a)
  in
  let y, x = forLoop140 (y, x) (b, a) in
  let rec whileLoop47271472 x =
    if Int.( < ) x 3 then x
    else
      let x = x - 1 in
      whileLoop47271472 x
  in
  let x = whileLoop47271472 x in
  let accum : int = 0 in
  let a : int = 0 in
  let rec forLoop5861662940 accum a =
    if Int.( < ) a 2 then accum
    else
      let b : int = 0 in
      let rec forLoop117233258835 accum b =
        if Int.( < ) b 2 then accum
        else
          let accum = Int.( + ) accum a in
          let b = b + 1 in
          forLoop117233258835 accum b
      in
      let accum = forLoop117233258835 accum b in
      let a = a + 1 in
      forLoop5861662940 accum a
  in
  let accum = forLoop5861662940 accum a in
  0
