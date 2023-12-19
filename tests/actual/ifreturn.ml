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
  let b : int = 3 in
  if Int.( > ) a 0 then
    let b = Int.( + ) b a in
    b
  else Int.( * ) b 2

let () =
  let x : int = foo 5 in
  exit 0
