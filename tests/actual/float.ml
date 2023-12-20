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
  let a : float = 1. in
  let b : float = 2.3 in
  let c : float = Float.( + ) a b in
  let d : float = Float.( * ) a b in
  let e =
    if Float.( = ) b 0. then
      let e = 0. in
      e
    else
      let e = Float.( / ) a b in
      e
  in
  printf "c = %f\n" c;
  printf "d = %f\n" d;
  exit 0
