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
  let i : int = 12 in
  let f : float = 4.2 in
  let ui : int = 12 in
  let uc : char = 'a' in
  let c : char = 'x' in
  let l : int = 123456789 in
  let ul : int = 123456789 in
  let s : int = 123 in
  let us : int = 123 in
  let d : float = 123.456 in
  let ld : float = 123.456 in
  let ll : int = 123456789 in
  let ull : int = 123456789 in
  exit 0
