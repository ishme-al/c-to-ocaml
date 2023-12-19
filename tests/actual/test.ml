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
  let arr : int list = List.init 5 ~f:(fun _ -> 0) in
  let arr = set_at_index arr 2 0 in
  let arr = set_at_index arr 3 (List.nth_exn arr 2) in
  let x : int = 0 in
  let rec while_main x =
    match Int.( < ) x 0 with
    | false -> x
    | true ->
        let z : int = 1 in
        let x = x + 1 in
        while_main x
  in
  let x = while_main x in
  let y : int = 0 in
  let z : int = 2 in
  let rec for_main () (y, x) =
    match Int.( < ) x 5 with
    | false -> (y, x)
    | true ->
        let x = Int.( + ) x 1 in
        let y = Int.( + ) y x in
        let x = x + 1 in
        for_main () (y, x)
  in
  let y, x = for_main () (y, x) in
  let e : int = 0 in
  let c : int = 0 in
  let rec for_main (c, e) (y, x) =
    match Int.( < ) e 5 with
    | false -> (y, x)
    | true ->
        let x = Int.( + ) x 1 in
        let y = Int.( + ) y x in
        let e = Int.( + ) e 1 in
        let e = e + 1 in
        for_main (c, e) (y, x)
  in
  let y, x = for_main (c, e) (y, x) in
  let y, z, x =
    if Int.( > ) x y then
      let x = Int.( + ) x 1 in
      let z = Int.( + ) 2 1 in
      let a : int = 3 in
      (y, z, x)
    else
      let y = Int.( + ) y 1 in
      (y, z, x)
  in
  let x =
    if Int.( = ) x 0 then
      let x = y in
      x
    else x
  in
  let x =
    if Int.( = ) x y then
      let x = Int.( + ) x y in
      x
    else x
  in
  exit 0
