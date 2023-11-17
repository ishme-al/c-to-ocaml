open Core
open Clang

[@@@ocaml.warning "-26"]

let read =
  Command.Arg_type.create (fun filename ->
      match filename with
      | "-" -> In_channel.(input_all stdin)
      | _ -> In_channel.read_all filename)

let write =
  Command.Arg_type.create (fun filename ->
      match filename with
      | "-" -> Out_channel.stdout
      | _ -> Out_channel.create filename)

(* let demo_output (input_file:string): Clang.Ast.translation_unit = 
   Clang.Ast.parse_file input_file *)


let command =
  Command.basic
    ~summary:"Transpile c to ocaml code"
    ~readme:(fun () -> "input-file: `-` for stdin\noutput-file: `-` for stdout")
    (let%map_open.Command
      watch = flag "-w" no_arg ~doc:"watch mode"
     and input = anon ("[input-file]" %: read)
     and output = anon ("[output-file]" %: write)
     in
     fun () ->
       if watch 
       then failwith "Not implemented"
       else 
         (* let parsed_ast = demo_output input in *)
         (* let itemList = parsed_ast.desc in *)
         Out_channel.output_string output input)

let () = Command_unix.run ~version:"0.1" ~build_info:"not sure what this is" command


let rec traverse_node node =
  match node with
  | TranslationUnit (_, decl_list, _) ->
    List.iter traverse_decl decl_list

and traverse_decl decl =
  match decl with
  | FunctionDecl (_, name_info, _, _) ->
    print_endline ("Function: " ^ name_info.ni_name)
  | _ -> ()

let traverse_ast c_ast =
  match c_ast with
  | TranslationUnit (_, decl_list, _) ->
    List.iter traverse_decl decl_list


let rec print_node depth (node) =
  let indent = String.make (2 * depth) ' ' in
  match node.desc with
  | Translation_unit decl_list ->
    Printf.printf "%sTranslation_unit\n" indent;
    List.iter (print_node (depth + 1)) decl_list

  | Function_decl name_info ->
    Printf.printf "%sFunction_decl: %s\n" indent name_info.ni_name;
    Printf.printf "%s  Return Type: int\n" indent;
    Printf.printf "%s  Function Body:\n" indent;
    match node.desc with
    | { desc = Function_decl _; _ } ->
      print_node (depth + 2) (node.desc)
    | _ -> ()

    | Compound_stmt stmt_list ->
      Printf.printf "%sCompound_stmt\n" indent;
      List.iter (print_node (depth + 1)) stmt_list

    | Return_stmt expr_info ->
      Printf.printf "%sReturn_stmt\n" indent;
      match node.desc with
      | { desc = Integer_literal _; _ } ->
        print_node (depth + 1) (node.desc)
      | _ -> ()

      | Integer_literal value ->
        Printf.printf "%sInteger_literal: %s\n" indent value

      | _ ->
        Printf.printf "%sUnhandled node type\n" indent

let visualize_ast c_ast =
  print_node 0 c_ast