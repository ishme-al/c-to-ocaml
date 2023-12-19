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

let foo () () = ()

let () =
  let x : int list = [ 1; 2; 3 ] in
  let y : float = 2. in
  printf "Hello, world %d %.2f!\n" (List.nth_exn x 1) y;
  exit 0
