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
let b : int list = [1 ; 2 ; 3 ; ] in
let sum : int = 0  in
let x : int = 0  in
let rec for_main (sum) (x) = if not @@ Int.( < ) x 3  then (sum) 
 else let sum  = Int.( + ) sum (List.nth_exn b x)  in
let x  = x  + 1 in
for_main (sum) (x) in 
let (sum) = for_main (sum) (x) in 
let i : int = 0  in
let rec for_main (b) (i) = if not @@ Int.( < ) i 3  then (b) 
 else let b = set_at_index b i( Int.( + ) (List.nth_exn b i) 1 ) in
(printf "%d, " (List.nth_exn b i) );let i  = Int.( + ) i 1  in
for_main (b) (i) in 
let (b) = for_main (b) (i) in 
let x : int = Int.( + ) (List.nth_exn b 2) 3  in
let b = set_at_index b 1( 3 ) in
let a : int list = List.init 3 ~f:(fun _ -> 0) in 
exit(0 )
