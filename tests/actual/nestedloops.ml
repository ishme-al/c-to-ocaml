[@@@ocaml.warning "-26"] 

  [@@@ocaml.warning "-27"]

  open Core 

  let rec set_at_index (lst: 'a list) (index:int) (value: 'a) : 'a list =
    match lst with
    | [] -> failwith "Index out of bounds"
    | hd :: tl ->
      if index = 0 then
        value :: tl
      else
        hd :: set_at_index tl (index - 1) value 
 let foo  : int = 
let x : int = 0  in
let i : int = 0  in
let rec for_foo (x) (i) = if not @@ Int.( < ) i 5  then (x) 
 else let j : int = 0  in
let rec for_for_foo (x) (j) = if not @@ Int.( < ) j 3  then (x) 
 else let x  = x  + 1 in
let j  = j  + 1 in
for_for_foo (x) (j) in 
let (x) = for_for_foo (x) (j) in 
let i  = i  + 1 in
for_foo (x) (i) in 
let (x) = for_foo (x) (i) in 
let i : int = 0  in
let rec for_foo (x) (i) = if not @@ Int.( < ) i 3  then (x) 
 else let rec while_for_foo (x) = if not @@ Int.( > ) x 3  then (x) 
 else let x  = x  - 1 in
while_for_foo (x) in 
let x = while_for_foo (x) in 
let i  = i  + 1 in
for_foo (x) (i) in 
let (x) = for_foo (x) (i) in 
x 