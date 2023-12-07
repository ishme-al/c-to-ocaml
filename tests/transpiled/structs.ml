type myStructure = { a : int; b : int; c : char; d : float }

let transformAB (str : myStructure) : int =
  let c : int = str.a * str.b in
  let b : int = str.a + str.b in
  b + c

let addAb (str : myStructure) : int = str.a + str.b
let multAb (str : myStructure) : int = str.a * str.b
let subAb (str : myStructure) : int = str.a - str.b
let divideAb (str : myStructure) : int = str.a / str.b
