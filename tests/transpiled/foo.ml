[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]

open Core

let foo (a : float) (b : float) : float =
  let y, x =
    if Float.( < ) a b then
      let z : float = 2 in
      let x = Float.( - ) b a in
      let y = Float.( + ) z a in
      (y, x)
    else
      let z : float = 3 in
      let x = Float.( - ) a b in
      let y = Float.( + ) z b in
      (y, x)
  in
  Float.( + ) x y

let () =
  let x : float = foo (foo 4 6) 3 in
  exit 0
