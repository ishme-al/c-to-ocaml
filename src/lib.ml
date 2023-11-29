open Core
open Clang

[@@@ocaml.warning "-26"]

let rec visit_stmt (ast : Ast.stmt) (out : Out_channel.t) : unit =
  match ast.desc with
  | Compound stmt_list -> List.iter ~f:(fun stmt -> visit_stmt stmt out) stmt_list
  | Return None -> failwith "uhoh"
  (* | Return Some r -> Out_channel.fprintf out "return %d" @@ Int.of_string r *)
  | _ -> Clang.Printer.stmt Format.std_formatter ast
  (* | _ *)

let visit_function_decl (ast : Ast.function_decl) (out : Out_channel.t) : unit =
  match ast.name with
  | IdentifierName "main" -> Out_channel.output_string out @@ "let () =\n"; visit_stmt (Option.value_exn ast.body) out
  | IdentifierName name -> Out_channel.output_string out @@ "let " ^ name ^ " = \n"; visit_stmt (Option.value_exn ast.body) out
  | _ -> failwith "???"

let visit_decl (ast : Ast.decl) (out : Out_channel.t) : unit =
  match ast.desc with
  | Function function_decl ->
    visit_function_decl function_decl out
    | _ ->
      Clang.Printer.decl Format.std_formatter ast




let custom_print (depth: int) (node:Clang.Decl.t) (out : Out_channel.t) : unit =
  let indent = String.make (2 * depth) ' ' in
  match node.desc with
  | Clang.Ast.Function hello ->
    let name = match hello.name with
      | Clang.Ast.IdentifierName a -> a 
      | _ -> "hello" in
    Out_channel.output_string out @@ (indent ^ "Function_decl:" ^ name ^ " \n");
    (* Stdio.printf "%sFunction_decl: %s\n" indent name *)
    (* Printf.printf "%s  Return Type: int\n" indent; *)
    Out_channel.output_string out @@ (indent ^ "Function_body:" ^"\n");
    (* Stdio.printf "%s  Function Body:\n" indent; *)
    (* will have further recursion to print out more about what is inside function*)
  | _ ->    Out_channel.output_string out @@ indent ^ "Unsupported \n"

     (* Stdio.printf "%s  unsupported o\n" indent *)


let visualize_ast (ast:Translation_unit.t) (out : Out_channel.t) : unit =
  let foo =
    match ast with
    | { desc = { items = [foo]; _ }; _ } -> foo
    | _ -> assert false in
  custom_print 0 foo out

  let parse (ast : Ast.translation_unit) (out : Out_channel.t) : unit =
    let x = visualize_ast ast out in
    List.iter ~f:(fun item -> visit_decl item out) ast.desc.items
