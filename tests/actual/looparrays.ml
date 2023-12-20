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
  let b : int list = [ 1; 2; 3 ] in
  let sum : int = 0 in
  let x : int = 0 in
  let rec for_main x sum =
    match Int.( < ) x 3 with
    | false -> sum
    | true ->
        let sum = Int.( + ) sum (List.nth_exn b x) in
        let x = x + 1 in
        for_main x sum
  in
  let sum = for_main x sum in
  let i : int = 0 in
  let rec for_main i b =
    match Int.( < ) i 3 with
    | false -> b
    | true ->
        let b = set_at_index b i (Int.( + ) (List.nth_exn b i) 1) in
        let b = set_at_index b i (List.nth_exn b i) in
        printf "%d, " (List.nth_exn b i);
        let b = set_at_index b i (Int.( + ) (List.nth_exn b i) 1) in
        let i = Int.( + ) i 1 in
        for_main i b
  in
  let b = for_main i b in
  let x : int = Int.( + ) (List.nth_exn b 2) 3 in
  let b = set_at_index b 1 3 in
  let a : int list = List.init 3 ~f:(fun _ -> 0) in
  exit 0
