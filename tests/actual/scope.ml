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

let () =
  let a : int = 1 in
  let b : float = 3. in
  let b =
    if Int.( < ) a 2 then
      let a : float = 2. in
      let b = a in
      b
    else b
  in
  let a = 3 in
  exit 0
