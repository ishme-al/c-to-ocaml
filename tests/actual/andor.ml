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
  let b : int = 2 in
  let c : int = 3 in
  let c =
    if Int.( = ) a 1 && Int.( = ) b 2 then
      let c = 4 in
      c
    else c
  in
  let c =
    if Int.( = ) a 1 || Int.( = ) b 2 then
      let c = 5 in
      c
    else c
  in
  printf "%d\n" c;
  exit 0
