open Core
open Clang

[@@@ocaml.warning "-26"]

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
  | Some params when params.variadic ->
      failwith "Variadic functions are not supported"
  | Some params -> List.fold ~f:parse_param params.non_variadic ~init:""
  | None -> ""

let parse_func_return_type (ast : Ast.function_decl) : string =
  parse_qual_type ast.function_type.result

(* TODO: how handle operations on types other than ints? *)
let parse_binary_operator (op_kind : Ast.binary_operator_kind) : string =
  match op_kind with
  | Add -> "+"
  | Sub -> "-"
  | _ -> failwith "handle others later"

let rec visit_stmt (ast : Ast.stmt) : string =
  match ast.desc with
  | Compound stmt_list -> List.fold ~init:"" ~f:(fun s stmt -> s ^ visit_stmt stmt) stmt_list
  | Decl decl_list -> List.fold ~init:"" ~f:(fun s decl -> s ^ visit_decl decl) decl_list
  | Return Some ret_expr -> visit_expr ret_expr 
  | Return None -> failwith "uhoh"
  (* | Return Some r -> Out_channel.fprintf out "return %d" @@ Int.of_string r *)
  | _ -> Clang.Printer.stmt Format.std_formatter ast; ""
  (* | _ *)

and visit_function_decl (ast : Ast.function_decl) : string =
  match ast.name with
  | IdentifierName "main" -> "let () =\n" ^ visit_stmt (Option.value_exn ast.body) (* TODO: FIX *)
  | IdentifierName name ->
      "let " ^ name ^ " " ^ parse_func_params ast ^ ": "
      ^ parse_func_return_type ast ^ " = \n" ^
      visit_stmt (Option.value_exn ast.body)
  | _ -> failwith "failure in visit_function_decl"

and visit_decl (ast : Ast.decl) : string =
  match ast.desc with
  | Function function_decl ->
    visit_function_decl function_decl
  | Var var_decl -> (
    "let " ^ var_decl.var_name ^ " : " ^ (parse_qual_type var_decl.var_type) ^ " = " ^ (visit_expr @@ Option.value_exn var_decl.var_init) ^ " in\n"
  )
  | _ ->
      Clang.Printer.decl Format.std_formatter ast; ""

and visit_expr (ast: Ast.expr) : string =
  match ast.desc with
  | BinaryOperator {lhs; rhs; kind} -> (
    visit_expr lhs ^ " " ^ parse_binary_operator kind ^ " " ^ visit_expr rhs ^ "\n"
  )
  | DeclRef d -> (
    match d.name with
    | IdentifierName name -> name
    | _ -> assert false
  )
  | IntegerLiteral i -> (
    match i with
    | Int value -> Int.to_string value
    | _ -> assert false
  )
  | _ -> Clang.Printer.expr Format.std_formatter ast; ""

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