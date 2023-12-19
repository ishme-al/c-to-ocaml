[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]
[@@@ocaml.warning "-32"]

open Core

let rec set_at_index (lst : 'a list) (index : int) (value : 'a) : 'a list =
  match lst with
  | [] -> failwith "Index out of bounds"
  | hd :: tl ->
      if index = 0 then value :: tl else hd :: set_at_index tl (index - 1) value

let foo (x : int list) : int =
  let x = set_at_index x 0 0 in
  List.nth_exn x 0

let () =
  let x : int list = [ 1; 2; 3 ] in
  printf "x array:\n";
  let i : int = 0 in
  let rec for_main i x =
    match Int.( < ) i 3 with
    | false -> x
    | true ->
        let x = set_at_index x i (Int.( + ) (List.nth_exn x i) 1) in
        printf "%d, " (List.nth_exn x i);
        let i = Int.( + ) i 1 in
        for_main i x
  in
  let x = for_main i x in
  let j : int = 2 in
  let rec while_main j =
    match Int.( > ) j 0 with
    | false -> j
    | true ->
        printf "%d, " (List.nth_exn x j);
        let j = Int.( - ) j 1 in
        while_main j
  in
  let j = while_main j in
  let y : int = foo x in
  printf "\ny: %d\n" y;
  exit 0
