open Core
open OUnit2

[@@@warning "-32"]
[@@@warning "-27"]

let output_folder = "actual/"
let source_folder = "source/"
let expected_folder = "expected/"

let clear () : unit =
  Sys_unix.readdir output_folder
  |> Array.iter ~f:(fun filename ->
         Sys_unix.remove @@ output_folder ^ filename)

let transpile () : unit =
  Sys_unix.readdir source_folder
  |> Array.iter ~f:(fun filename ->
         let filename = String.drop_suffix filename 1 in
         let data =
           source_folder ^ filename ^ "c"
           |> In_channel.read_all |> Lib.parse
           |> Lib.format @@ filename ^ "ml"
           |> Option.value_exn
         in
         Out_channel.write_all ~data @@ output_folder ^ filename ^ "ml")

let dune () : unit =
  let data =
    Sys_unix.readdir output_folder
    |> Array.fold ~init:"" ~f:(fun acc filename ->
           let filename = String.drop_suffix filename 3 in
           acc ^ "(executable (name " ^ filename ^ ") (modules " ^ filename
           ^ ") (libraries core))\n")
  in
  Out_channel.write_all (output_folder ^ "dune") ~data

  (* ocamlfind ocamlopt -o int -linkpkg -package core int.ml *)
let compile ctxt : unit =
  Sys_unix.readdir output_folder |> Array.iter ~f:(fun filename ->
    if String.(filename <> "dune") then
    let exit_code = Option.some @@ Caml_unix.WEXITED 0 in
    assert_command ?exit_code ~ctxt "ocamlfind" [ "ocamlopt"; "-o"; output_folder ^ String.drop_suffix filename 3; "-linkpkg"; "-package"; "core"; output_folder ^ filename]
    )

(* commented out:
  test.c
  print.c
  error.c
  foo.c
  recursive.c
  arrayfunc.c
  scope.c
  int.c
*)

let return_code (filename : string) : Caml_unix.process_status option =
  let rc =
    match filename with
    | "array.ml" -> 0
    | "arrayfunc.ml" -> 0
    | "char.ml" -> 0
    | "comments.ml" -> 0
    | "dune" -> 0
    | "elseif.ml" -> 0
    | "error.ml" -> 0
    | "float.ml" -> 0
    | "foo.ml" -> 0
    | "foo2.ml" -> 0
    | "if.ml" -> 0
    | "if2.ml" -> 0
    | "ifarrays.ml" -> 0
    | "ifreturn.ml" -> 0
    | "int.ml" -> 0
    | "functions.ml" -> 0
    | "loops.ml" -> 0
    | "looparrays.ml" -> 0
    | "main.ml" -> 0
    | "nestedloops.ml" -> 0
    | "print.ml" -> 0
    | "recursive.ml" -> 0
    | "scope.ml" -> 0
    | "statements.ml" -> 0
    | "struct.ml" -> 0
    | "structs.ml" -> 0
    | "test.ml" -> 0
    | "voidfunc.ml" -> 0
    | _ -> assert_failure @@ filename ^ " return code not implemented"
  in
  Option.some @@ Caml_unix.WEXITED rc

let expected (filename : string) : string =
  let filename = String.drop_suffix filename 2 ^ "txt" in
  In_channel.read_all @@ expected_folder ^ "/" ^ filename
  |> Fun.flip String.drop_suffix 1 (* file newline *)

let run ctxt : unit =
  Sys_unix.readdir output_folder
  |> Array.iter ~f:(fun filename ->
          if Result.is_ok @@ Core_unix.access "" [`Exec] then
           let path = "actual/" ^ String.drop_suffix filename 2 ^ "exe" in
           assert_command ?exit_code:(return_code filename)
             ?foutput:
               ( Option.some (fun s ->
                 assert_equal (expected filename)
                 @@ (Sequence.of_seq s |> Sequence.to_list |> String.of_char_list ) 
        ))
             ~ctxt path [])


let test ctxt =
  Sys_unix.chdir "../../../tests";
  clear ();
  transpile ();
  dune ();
  Printf.printf "%s\n" @@ Sys_unix.getcwd ();
  compile ctxt;
  run ctxt;
  Sys_unix.chdir "../_build/default/tests/" (* must come back for ounit2 *)

let tests = "test" >::: [ "check" >:: test ]
let series = "Tests" >::: [ tests ]
let () = run_test_tt_main series
