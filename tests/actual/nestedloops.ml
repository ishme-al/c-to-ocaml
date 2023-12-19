[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]
[@@@ocaml.warning "-32"]

open Core

let rec set_at_index (lst : 'a list) (index : int) (value : 'a) : 'a list =
  match lst with
  | [] -> failwith "Index out of bounds"
  | hd :: tl ->
      if index = 0 then value :: tl else hd :: set_at_index tl (index - 1) value

let foo : int =
  let x : int = 0 in
  let i : int = 0 in
  let rec for_foo i x =
    match Int.( < ) i 5 with
    | false -> x
    | true ->
        let j : int = 0 in
        let rec for_for_foo j x =
          match Int.( < ) j 3 with
          | false -> x
          | true ->
              let x = x + 1 in
              let j = j + 1 in
              for_for_foo j x
        in
        let x = for_for_foo j x in
        let i = i + 1 in
        for_foo i x
  in
  let x = for_foo i x in
  let i : int = 0 in
  let rec for_foo i x =
    match Int.( < ) i 3 with
    | false -> x
    | true ->
        let rec while_for_foo x =
          match Int.( > ) x 3 with
          | false -> x
          | true ->
              let x = x - 1 in
              while_for_foo x
        in
        let x = while_for_foo x in
        let i = i + 1 in
        for_foo i x
  in
  let x = for_foo i x in
  x
