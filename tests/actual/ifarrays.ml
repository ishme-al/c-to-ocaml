[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]
[@@@ocaml.warning "-32"]
[@@@ocaml.warning "-69"]

open Core

let rec set_at_index (lst : 'a list) (index : int) (value : 'a) : 'a list =
  match lst with
  | [] -> failwith "Index out of bounds"
  | hd :: tl ->
      if index = 0 then value :: tl else hd :: set_at_index tl (index - 1) value

let () =
  let b : int list = [ 1; 2; 3 ] in
  let sum : int = 0 in
  let sum =
    if Int.( = ) sum 0 then
      let sum = List.nth_exn b sum in
      sum
    else sum
  in
  exit 0
