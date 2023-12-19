open Core
open OUnit2

let output_folder = "../../../tests/actual"
let source_folder = "../../../tests/source"
let expected_folder = "../../../tests/expected"

let clear () : unit =
  Sys_unix.readdir output_folder
  |> Array.iter ~f:(fun filename ->
         Sys_unix.remove @@ output_folder ^ "/" ^ filename)

let transpile () : unit =
  Sys_unix.readdir source_folder
  |> Array.iter ~f:(fun filename ->
         let filename = String.drop_suffix filename 1 in
         let data =
           source_folder ^ "/" ^ filename ^ "c"
           |> In_channel.read_all |> Lib.parse
           |> Lib.format @@ filename ^ "ml"
           |> Option.value_exn
         in
         Out_channel.write_all ~data @@ output_folder ^ "/" ^ filename ^ "ml")

let dune () : unit =
  let data =
    Sys_unix.readdir output_folder
    |> Array.fold ~init:"" ~f:(fun acc filename ->
           let filename = String.drop_suffix filename 3 in
           acc ^ "(executable (name " ^ filename ^ ") (modules " ^ filename
           ^ ") (libraries core))\n")
  in
  Out_channel.write_all (output_folder ^ "/dune") ~data

let compile ctxt : unit =
  let exit_code = Option.some @@ Caml_unix.WEXITED 0 in
  assert_command ?exit_code ~ctxt "dune" [ "build" ]

(* commented out:
  test.c
  print.c
  error.c
  foo.c
  recursive.c
  structs.c
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

let expected (filename : string) : char list =
  let filename = String.drop_suffix filename 2 ^ "txt" in
  In_channel.read_all @@ expected_folder ^ "/" ^ filename
  |> Fun.flip String.drop_suffix 1
  |> String.to_list

let run ctxt : unit =
  Sys_unix.readdir output_folder
  |> Array.iter ~f:(fun filename ->
         if String.(filename <> "dune") then (
           printf "Running %s\n" filename;
           let path = "actual/" ^ String.drop_suffix filename 2 ^ "exe" in
           assert_command ?exit_code:(return_code filename)
             ?foutput:
               ( Option.some @@ fun s ->
                 assert_equal
                   ~printer:(List.to_string ~f:Char.to_string)
                   (expected filename)
                 @@ (Sequence.of_seq s |> Sequence.to_list) )
             ~ctxt path []) else ())

let test ctxt =
  clear ();
  transpile ();
  dune ();
  compile ctxt;
  run ctxt

let tests = "test" >::: [ "check" >:: test ]
let series = "Tests" >::: [ tests ]
let () = run_test_tt_main series
