open Core
open Clang
open Utils

[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]

let rec visit_stmt (ast : Ast.stmt) (func_name : string) : string =
  match ast.desc with
  | Compound stmt_list ->
      List.fold ~init:""
        ~f:(fun s stmt -> s ^ visit_stmt stmt func_name)
        stmt_list
  | Decl decl_list ->
      List.fold ~init:"" ~f:(fun s decl -> s ^ visit_decl decl) decl_list
  | Expr expr -> visit_expr expr
  | If { cond; then_branch; else_branch; _ } ->
      visit_if_stmt cond then_branch else_branch func_name
  | Return (Some ret_expr) -> (
      match func_name with
      | "main" -> "exit(" ^ visit_expr ret_expr ^ ")\n"
      | _ -> visit_expr ret_expr)
  | Return None -> failwith "uhoh"
  | _ ->
      Clang.Printer.stmt Format.std_formatter ast;
      ""

and visit_if_stmt (cond : Ast.expr) (then_branch : Ast.stmt)
    (else_branch : Ast.stmt option) (func_name : string) : string =
  let mutated =
    Collect_vars.collect_mutated_vars then_branch [] |> fun l ->
    match else_branch with
    | Some e -> Collect_vars.collect_mutated_vars e l
    | None -> l
  in
  let return_str = " (" ^ String.concat ~sep:"," mutated ^ ") " in
  let else_str =
    match else_branch with
    | Some e -> "else " ^ visit_stmt e func_name ^ return_str
    | None -> ""
  in
  "let " ^ return_str ^ " = if " ^ visit_expr cond ^ " then "
  ^ visit_stmt then_branch func_name
  ^ return_str ^ else_str ^ " in\n"

and visit_function_decl (ast : Ast.function_decl) : string =
  match ast.name with
  | IdentifierName "main" ->
      "let () =\n"
      ^ visit_stmt (Option.value_exn ast.body) "main" (* TODO: FIX *)
  | IdentifierName name ->
      "let " ^ name ^ " " ^ parse_func_params ast ^ ": "
      ^ parse_func_return_type ast ^ " = \n"
      ^ visit_stmt (Option.value_exn ast.body) name
  | _ -> failwith "failure in visit_function_decl"

and visit_struct_decl (ast : Ast.record_decl) : string =
  let name = ast.name in
  "type " ^ name ^ " = { "
  ^ List.fold ~init:"" ~f:(fun s item -> s ^ visit_decl item) ast.fields
  ^ "} "

and visit_decl (ast : Ast.decl) : string =
  match ast.desc with
  | Function function_decl -> visit_function_decl function_decl
  | Var var_decl -> (
      match var_decl.var_init with
      | Some var_init ->
          "let " ^ var_decl.var_name ^ " : "
          ^ parse_qual_type var_decl.var_type
          ^ " = " ^ visit_expr var_init ^ " in\n"
      | None -> "")
  | RecordDecl struct_decl -> visit_struct_decl struct_decl
  | Field { name; qual_type; _ } ->
      name ^ ": " ^ parse_qual_type qual_type ^ "; "
  | EmptyDecl -> ""
  | _ ->
      Clang.Printer.decl Format.std_formatter ast;
      ""

and visit_struct_expr (ast : Ast.expr) : string =
  match ast.desc with
  | Member s ->
      let tempStruct = Option.value_exn s.base in
      let name =
        match tempStruct.desc with
        | DeclRef d -> (
            match d.name with IdentifierName name -> name | _ -> assert false)
        | _ -> failwith "handle other cases later"
      in
      let field = s.field in
      let fieldName =
        match field with
        | FieldName f -> (
            match f.desc.name with
            | IdentifierName i -> i
            | _ -> failwith "handle edge case later")
        | _ -> failwith "handle other cases later"
      in
      name ^ "." ^ fieldName ^ " "
  | _ -> failwith "handle other cases later"

and visit_expr (ast : Ast.expr) : string =
  match ast.desc with
  | BinaryOperator { lhs; rhs; kind } -> (
      match kind with
      | Assign -> "let " ^ visit_expr lhs ^ " = " ^ visit_expr rhs ^ " in\n"
      | _ ->
          visit_expr lhs ^ " " ^ parse_binary_operator kind ^ " "
          ^ visit_expr rhs ^ "\n")
  | DeclRef d -> (
      match d.name with IdentifierName name -> name ^ " " | _ -> assert false)
  | IntegerLiteral i -> (
      match i with Int value -> Int.to_string value ^ " " | _ -> assert false)
  | Member s -> visit_struct_expr ast
  | Call { callee; args } ->
      "(" ^ visit_expr callee
      ^ List.fold ~init:" " ~f:(fun s arg -> s ^ visit_expr arg) args
      ^ ")"
  | _ ->
      Clang.Printer.expr Format.std_formatter ast;
      ""

let parse (source : string) : string =
  let ast = Clang.Ast.parse_string source in
  List.fold ~init:"" ~f:(fun s item -> s ^ visit_decl item) ast.desc.items
