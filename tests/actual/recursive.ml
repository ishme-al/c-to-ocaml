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
 let rec foo (a : int)  : int = 
if Int.( > ) a 0  then (foo Int.( - ) a 1 ) else 0 
let () =
let x : int = (foo 5 ) in
exit(0 )
