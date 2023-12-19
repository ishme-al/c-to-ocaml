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
  let x : int = Int.( + ) (List.nth_exn b 2) 3 in
  let b = set_at_index b 1 3 in
  let a : int list = List.init 3 ~f:(fun _ -> 0) in
  exit 0
