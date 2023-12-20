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

let rec recursive (n : int) : int =
  printf "recursive(%d)\n" n;
  if Int.( > ) n 1 then recursive (recursive (Int.( - ) n 1)) else n

let () =
  let x : int = recursive 5 in
  exit 0
