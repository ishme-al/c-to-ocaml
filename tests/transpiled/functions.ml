let test1 (a : int) (b : int) : int = a + b
let test2 (a : int) (b : char) : int = a

let test3 (a : int) (b : char) : char =
  let a = a * 2 in
  let a = a + 3 in
  b
