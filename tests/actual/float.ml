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
 let () =
let a : float = 1.  in
let b : float = 2.3  in
exit(0 )
