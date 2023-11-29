open Core
open Clang

(* let rec traverse_node node = *)
(*   match node with *)
(*   | TranslationUnit (_, decl_list, _) -> *)
(*     List.iter traverse_decl decl_list *)
(**)
(* and traverse_decl decl = *)
(*   match decl with *)
(*   | FunctionDecl (_, name_info, _, _) -> *)
(*     print_endline ("Function: " ^ name_info.ni_name) *)
(*   | _ -> () *)
(**)
(* let traverse_ast c_ast = *)
(*   match c_ast with *)
(*   | TranslationUnit (_, decl_list, _) -> *)
(*     List.iter traverse_decl decl_list *)
(**)

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
  (* | Translation_unit decl_list -> *)
  (*   Printf.printf "%sTranslation_unit\n" indent; *)
  (*   List.iter (print_node (depth + 1)) decl_list *)

  | Function function_decl ->
    visit_function_decl function_decl out
(*     match node.desc with *)
(*     | { desc = Function_decl _; _ } -> *)
(*       print_node (depth + 2) (node.desc) *)
(*     | _ -> () *)
(**)
(*     | Compound_stmt stmt_list -> *)
(*       Printf.printf "%sCompound_stmt\n" indent; *)
(*       List.iter (print_node (depth + 1)) stmt_list *)
(**)
(*     | Return_stmt expr_info -> *)
(*       Printf.printf "%sReturn_stmt\n" indent; *)
(*       match node.desc with *)
(*       | { desc = Integer_literal _; _ } -> *)
(*         print_node (depth + 1) (node.desc) *)
(*       | _ -> () *)
(**)
      (* | Integer_literal value -> *)
      (*   Printf.printf "%sInteger_literal: %s\n" indent value *)
(**)
    | _ ->
      Clang.Printer.decl Format.std_formatter ast

let parse (ast : Ast.translation_unit) (out : Out_channel.t) : unit =
  List.iter ~f:(fun item -> visit_decl item out) ast.desc.items
