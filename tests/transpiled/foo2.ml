let foo (a : int) (b : int) : int =
  let x : int = a in
  let y : int = b in
  x + y

let () =
  let x : int = foo (foo 4 6) 3 in
  exit 0
