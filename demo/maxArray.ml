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

let maxArray (arr : int list) : int =
  let max : int = List.nth_exn arr 0 in
  let i : int = 1 in
  let rec for_maxArray i max =
    match Int.( < ) i 20 with
    | false -> max
    | true ->
        let max =
          if Int.( >= ) (List.nth_exn arr i) max then
            let max = List.nth_exn arr i in
            max
          else max
        in
        let i = Int.( + ) i 1 in
        for_maxArray i max
  in
  let max = for_maxArray i max in
  max

let () =
  let arr : int list =
    [ 1; 2; 3; 4; 5; 6; 7; 8; 20; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 9 ]
  in
  let max : int = maxArray arr in
  printf "max: %d\n" max;
  exit 0
