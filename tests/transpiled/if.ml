[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]

open Core

let () =
  let x : int = 0 in
  let y : int = 0 in
  let y, x =
    if Int.( > ) x y then
      let x = Int.( + ) x 1 in
      (y, x)
    else
      let y = Int.( + ) y 1 in
      (y, x)
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
