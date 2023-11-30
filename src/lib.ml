open Core
open Clang

[@@@ocaml.warning "-26"]

let rec visit_stmt (ast : Ast.stmt) : string =
  match ast.desc with
  | Compound stmt_list -> List.fold ~init:"" ~f:(fun s stmt -> s ^ visit_stmt stmt) stmt_list
  | Return None -> failwith "uhoh"
  (* | Return Some r -> Out_channel.fprintf out "return %d" @@ Int.of_string r *)
  | _ -> Clang.Printer.stmt Format.std_formatter ast; ""
  (* | _ *)

(* returns the OCaml equivalent type of a qual_type *)
let parse_qual_type (q : Ast.qual_type) : string =
  match q.desc with
  | BuiltinType builtintype -> (
      match builtintype with
      | Long | Int -> "int"
      | UChar -> "char"
      | Float -> "float"
      | _ -> failwith "handle others later")
  | _ -> failwith "handle others later"

let parse_func_params (ast : Ast.function_decl) : string =
  let parse_param (acc : string) (p : Ast.parameter) =
    acc ^ "(" ^ p.desc.name ^ " : " ^ parse_qual_type p.desc.qual_type ^ ") "
  in
  match ast.function_type.parameters with
  (* function_type.parameters gives list of parameters
     function_type.result given return type of function *)
  | Some params when params.variadic ->
      failwith "Variadic functions are not supported"
  | Some params -> List.fold ~f:parse_param params.non_variadic ~init:""
  | None -> ""

let parse_func_return_type (ast : Ast.function_decl) : string =
  parse_qual_type ast.function_type.result

let visit_function_decl (ast : Ast.function_decl) : string =
  match ast.name with
  | IdentifierName "main" -> "let () =\n" ^ visit_stmt (Option.value_exn ast.body) (* TODO: FIX *)
  | IdentifierName name ->
      "let " ^ name ^ " " ^ parse_func_params ast ^ ": "
      ^ parse_func_return_type ast ^ " = \n" ^
      visit_stmt (Option.value_exn ast.body)
  | _ -> failwith "failure in visit_function_decl"

let visit_decl (ast : Ast.decl) : string =
  match ast.desc with
  | Function function_decl ->
    visit_function_decl function_decl
  | _ ->
      Clang.Printer.decl Format.std_formatter ast; ""




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

  let parse (ast : Ast.translation_unit) : string =
    let x = visualize_ast ast in
    List.fold ~init:"" ~f:(fun s item -> s ^ visit_decl item) ast.desc.items
