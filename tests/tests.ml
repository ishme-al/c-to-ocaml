open Core
open OUnit2

[@@@warning "-32"]
[@@@warning "-27"]

let tests_folder = "../../../tests/"
let test_build_folder = "../_build/default/tests/"
let output_folder = "actual/"
let source_folder = "source/"
let expected_folder = "expected/"

let clear () : unit =
  Sys_unix.readdir output_folder
  |> Array.iter ~f:(fun filename -> Sys_unix.remove @@ output_folder ^ filename)

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

(* create dune file *)
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
  Sys_unix.readdir output_folder
  |> Array.filter ~f:(fun filename -> String.(filename <> "dune"))
  |> Array.iter ~f:(fun filename ->
         assert_command
           ?exit_code:(Option.some @@ Caml_unix.WEXITED 0)
           ~ctxt "ocamlfind"
           [
             "ocamlopt";
             "-o";
             output_folder ^ String.drop_suffix filename 3;
             "-linkpkg";
             "-package";
             "core";
             output_folder ^ filename;
           ])

let return_code (filename : string) : Caml_unix.process_status option =
  let rc =
    match filename with
    | "andor" -> 0
    | "array" -> 0
    | "arrayfunc" -> 0
    | "char" -> 0
    | "comments" -> 0
    | "dune" -> 0
    | "elseif" -> 0
    | "error" -> 0
    | "float" -> 0
    | "foo" -> 0
    | "foo2" -> 0
    | "if" -> 0
    | "if2" -> 0
    | "ifarrays" -> 0
    | "ifreturn" -> 0
    | "incdec" -> 0
    | "int" -> 0
    | "functions" -> 0
    | "loops" -> 0
    | "looparrays" -> 0
    | "main" -> 0
    | "nestedloops" -> 0
    | "print" -> 0
    | "recrec" -> 0
    | "recursive" -> 0
    | "scope" -> 0
    | "statements" -> 0
    | "struct" -> 0
    | "structs" -> 0
    | "test" -> 0
    | "types" -> 0
    | "voidfunc" -> 0
    | _ -> assert_failure @@ filename ^ " return code not implemented"
  in
  Option.some @@ Caml_unix.WEXITED rc

(* careful about unix file newline terminations *)
let expected (filename : string) : string =
  In_channel.read_all @@ expected_folder ^ filename ^ ".txt"

let run ctxt : unit =
  Sys_unix.readdir output_folder
  |> Array.filter ~f:(fun filename ->
         Result.is_ok @@ Core_unix.access (output_folder ^ filename) [ `Exec ])
  |> Array.iter ~f:(fun filename ->
         assert_command ?exit_code:(return_code filename)
           ?foutput:
             (Option.some (fun s ->
                  assert_equal ~printer:Fun.id ~msg:filename (expected filename)
                  @@ (Sequence.of_seq s |> Sequence.to_list
                    |> String.of_char_list)))
           ~ctxt (output_folder ^ filename) [])

(* delete dune file because it's a nuisance *)
let delete_dune () : unit = Sys_unix.remove @@ output_folder ^ "dune"

let test ctxt =
  Sys_unix.chdir tests_folder;
  clear ();
  transpile ();
  dune ();
  compile ctxt;
  run ctxt;
  delete_dune ();
  Sys_unix.chdir test_build_folder (* must come back for ounit2 *)

module Utils_Tests = struct
  let test_capitalize_first_letter _ =
    assert_equal "Hello" (Utils.capitalize_first_letter "hello");
    assert_equal "Hello" (Utils.capitalize_first_letter "Hello");
    assert_equal "" (Utils.capitalize_first_letter "")

  let test_parse_default_value _ =
    assert_equal "0" (Utils.parse_default_value "int");
    assert_equal "0.0" (Utils.parse_default_value "float");
    assert_equal "' '" (Utils.parse_default_value "char");
    assert_raises (Failure "Unsupported type void: unknown default value")
      (fun () -> Utils.parse_default_value "void");
    assert_raises (Failure "Unsupported type asdf: unknown default value")
      (fun () -> Utils.parse_default_value "asdf");
    assert_raises (Failure "Unsupported type : unknown default value")
      (fun () -> Utils.parse_default_value "")

  let utils_tests =
    "Utils tests"
    >::: [
           "capitalize_first_letter" >:: test_capitalize_first_letter;
           "parse_default_value" >:: test_parse_default_value;
         ]
end

let tests = "test" >::: [ "check output" >:: test; Utils_Tests.utils_tests ]
let series = "Tests" >::: [ tests ]
let () = run_test_tt_main series
