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

let foo (a : int) : int =
  if Int.( = ) a 0 then 0
  else
    let x : int = Int.( + ) 4 a in
    x

let () =
  let x : int = foo 5 in
  exit 0
