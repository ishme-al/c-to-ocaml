let foo (a : int) (b : int) : int =
  let y, x =
    if a < b then
      let z : int = 2 in
      let x = b - a in
      let y = z + a in
      (y, x)
    else
      let z : int = 3 in
      let x = a - b in
      let y = z + b in
      (y, x)
  in
  x + y

let () =
  let x : int = foo (foo 4 6) 3 in
  0
