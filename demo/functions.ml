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

let test1 (a : int) (b : int) : int = Int.( + ) a b
let test2 (a : int) (b : char) : int = a

let test3 (a : int) (b : char) : char =
  let a = Int.( * ) a 2 in
  let a = Int.( + ) a 3 in
  b

let test4 (a : int) (b : int) : char = if Int.( > ) a b then a else b

let rec fibonacci (n : int) : int =
  if Int.( <= ) n 1 then n
  else
    let temp : int = fibonacci (Int.( - ) n 1) in
    let temp2 : int = fibonacci (Int.( - ) n 2) in
    Int.( + ) temp temp2
