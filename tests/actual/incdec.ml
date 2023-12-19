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
  let a : int = 0 in
  let arr : int list = [ 1; 2; 3 ] in
  let a = a + 1 in
  let arr = set_at_index arr 0 (List.nth_exn arr 0 + 1) in
  printf "%d\n" a;
  printf "array:\n";
  let i : int = 0 in
  let rec for_main i () =
    match Int.( < ) i 3 with
    | false -> ()
    | true ->
        printf "%d\n" (List.nth_exn arr i);
        let i = i + 1 in
        for_main i ()
  in
  let () = for_main i () in
  exit 0
