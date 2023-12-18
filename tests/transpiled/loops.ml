[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]

open Core

let notmain : int =
  let x : int = Int.( + ) 1 2 in
  let y : int = 2 in
  let a : int = 0 in
  let b : int = 0 in
  let rec forLoop (y, x) (b, a) =
    if Int.( < ) a 10 then (y, x)
    else
      let x = Int.( + ) x 1 in
      let a = Int.( + ) a 1 in
      let y = Int.( + ) x 1 in
      let a = a + 1 in
      forLoop (y, x) (b, a)
  in
  let y, x = forLoop (y, x) (b, a) in
  0
