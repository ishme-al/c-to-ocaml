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

let foo (a : float) (b : float) : float =
  let y, x =
    if Float.( < ) a b then
      let z : float = 2. in
      let x = Float.( - ) b a in
      let y = Float.( + ) z a in
      (y, x)
    else
      let z : float = 3. in
      let x = Float.( - ) a b in
      let y = Float.( + ) z b in
      (y, x)
  in
  Float.( + ) x y

let () =
  let x : float = foo (foo 4. 6.) 3. in
  exit 0
