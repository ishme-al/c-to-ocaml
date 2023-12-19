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
 let notmain  : int = 
let x : int = Int.( + ) 1 2  in
let y : int = 2  in
let a : int = 0  in
let rec for_notmain () (a) = if not @@ Int.( < ) a 3  then () 
 else let a  = a  + 1 in
if Int.( > ) a 1  then  (  )  else 
let a  = a  + 1 in
for_notmain () (a) in 
let () = for_notmain () (a) in 
let rec while_notmain (x) = if not @@ Int.( < ) x 3  then (x) 
 else let x  = x  - 1 in
while_notmain (x) in 
let x = while_notmain (x) in 
0 