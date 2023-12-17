open Core
open Clang
open Utils
open Scope

[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]

let parse_func_params (ast : Ast.function_decl) (vars : string VarMap.t) :
    Scope.t =
  let parse_param (acc : Scope.t) (p : Ast.parameter) : Scope.t =
    let qual_type = parse_qual_type p.desc.qual_type in
    acc
    |> Scope.add_var p.desc.name qual_type
    |> Scope.add_string ("(" ^ p.desc.name ^ " : " ^ qual_type ^ ") ")
  in
  match ast.function_type.parameters with
  | Some params when params.variadic ->
      failwith "Variadic functions are not supported"
  | Some params -> List.fold ~f:parse_param params.non_variadic ~init:("", vars)
  | None -> ("", vars)

let rec visit_stmt (ast : Ast.stmt) (func_name : string)
    (vars : string VarMap.t) : Scope.t =
  match ast.desc with
  | Compound stmt_list ->
      List.fold ~init:("", vars)
        ~f:(fun s stmt ->
          Scope.aggregate s @@ visit_stmt stmt func_name @@ Scope.get_vars s)
        stmt_list
  | Decl decl_list ->
      List.fold ~init:("", vars)
        ~f:(fun s decl ->
          Scope.aggregate s @@ visit_decl decl @@ Scope.get_vars s)
        decl_list
  | Expr expr -> visit_expr expr vars
  | If { cond; then_branch; else_branch; _ } ->
      visit_if_stmt cond then_branch else_branch func_name vars
  | Return (Some ret_expr) -> (
      match func_name with
      | "main" ->
          ("", vars) |> Scope.add_string "exit("
          |> Scope.extend ~f:(visit_expr ret_expr)
          |> Scope.add_string ")\n"
      | _ -> ("", vars) |> Scope.extend ~f:(visit_expr ret_expr))
  | Return None -> ("", vars) |> Scope.add_string "()"
  | _ ->
      Clang.Printer.stmt Format.std_formatter ast;
      ("", vars)

and visit_if_stmt (cond : Ast.expr) (then_branch : Ast.stmt)
    (else_branch : Ast.stmt option) (func_name : string)
    (vars : string VarMap.t) : Scope.t =
  let mutated =
    Collect_vars.collect_mutated_vars then_branch [] |> fun l ->
    match else_branch with
    | Some e -> Collect_vars.collect_mutated_vars e l
    | None -> l
  and else_str (vars : string VarMap.t) =
    match else_branch with
    | Some e -> visit_stmt e func_name vars
    | None -> ("", vars)
  in
  match List.length mutated with
  | 0 ->
      (* TODO this might not work with some edge cases !!! *)
      ("", vars) |> Scope.add_string "if "
      |> Scope.extend ~f:(visit_expr cond)
      |> Scope.add_string " then "
      |> Scope.extend ~f:(visit_stmt then_branch func_name)
      |> Scope.add_string " else " |> Scope.extend ~f:else_str
      |> Scope.add_string "\n"
  | _ ->
      let return_str = " (" ^ String.concat ~sep:"," mutated ^ ") " in
      ("", vars)
      |> Scope.add_string @@ "let " ^ return_str ^ " = if "
      |> Scope.extend ~f:(visit_expr cond)
      |> Scope.add_string " then "
      |> Scope.extend ~f:(visit_stmt then_branch func_name)
      |> Scope.add_string @@ return_str ^ " else "
      |> Scope.extend ~f:else_str
      |> Scope.add_string @@ return_str ^ " in\n"

and visit_function_decl (ast : Ast.function_decl) (vars : string VarMap.t)
    : Scope.t =
  match ast.name with
  | IdentifierName "main" ->
      ("", vars)
      |> Scope.add_string "let () =\n"
      |> Scope.extend ~f:(visit_stmt (Option.value_exn ast.body) "main")
  | IdentifierName name ->
      let let_str =
        match Find_rec.find_rec_func name (Option.value_exn ast.body) with
        | true -> "let rec "
        | false -> "let "
      and return_str =
        match parse_func_return_type ast with
        | "unit" -> "()"
        | return_type -> " : " ^ return_type
      in
      ("", vars)
      |> Scope.add_string (let_str ^ name ^ " ")
      |> Scope.extend ~f:(parse_func_params ast)
      |> Scope.add_string (return_str ^ " = \n")
      |> Scope.extend ~f:(visit_stmt (Option.value_exn ast.body) name)
  | _ -> failwith "failure in visit_function_decl"

and visit_struct_decl (ast : Ast.record_decl) : string =
  let name = ast.name in
  "type " ^ name ^ " = { "
  ^ (Scope.get_string
    @@ List.fold ~init:Scope.empty
         ~f:(fun s item ->
           Scope.aggregate s @@ visit_decl item VarMap.empty)
         ast.fields)
  ^ "} "

and visit_decl (ast : Ast.decl) (vars : string VarMap.t) : Scope.t =
  match ast.desc with
  | Function function_decl -> visit_function_decl function_decl vars
  | Var var_decl -> (
      let var_type = parse_qual_type var_decl.var_type in
      match var_decl.var_init with
      | Some var_init ->
          ("", vars)
          |> Scope.add_var var_decl.var_name var_type
          |> Scope.add_string @@ "let " ^ var_decl.var_name ^ " : " ^ var_type
             ^ " = "
          |> Scope.extend ~f:(visit_expr var_init)
          |> Scope.add_string " in\n"
      | None -> ("", vars) |> Scope.add_var var_decl.var_name var_type)
  | RecordDecl struct_decl ->
      Scope.add_string (visit_struct_decl struct_decl) ("", vars)
  | Field { name; qual_type; _ } ->
      Scope.add_string
        (name ^ ": " ^ parse_qual_type qual_type ^ "; ")
        ("", vars)
  | EmptyDecl -> ("", vars)
  | _ ->
      Clang.Printer.decl Format.std_formatter ast;
      ("", vars)

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

and visit_expr (ast : Ast.expr) (vars : string VarMap.t) : Scope.t =
  match ast.desc with
  | BinaryOperator { lhs; rhs; kind } -> (
      let op_type =
        visit_expr lhs vars |> Scope.get_string |> String.strip
        |> Scope.get_var vars |> capitalize_first_letter
      in
      match kind with
      | Assign ->
          ("", vars) |> Scope.add_string "let "
          |> Scope.extend ~f:(visit_expr lhs)
          |> Scope.add_string " = "
          |> Scope.extend ~f:(visit_expr rhs)
          |> Scope.add_string " in\n"
      | _ ->
          ("", vars)
          |> Scope.add_string (parse_binary_operator kind op_type ^ " ")
          |> Scope.extend ~f:(visit_expr lhs)
          |> Scope.extend ~f:(visit_expr rhs))
  | DeclRef d -> (
      match d.name with
      | IdentifierName name -> ("", vars) |> Scope.add_string (name ^ " ")
      | _ -> assert false)
  | IntegerLiteral i -> (
      match i with
      | Int value -> ("", vars) |> Scope.add_string (Int.to_string value ^ " ")
      | _ -> assert false)
  | FloatingLiteral f -> (
      match f with
      | Float value ->
          let float_str = Float.to_string value in
          printf "float_str: %s\n" float_str; (* THIS DOESNT WORK *)
          ("", vars)
          |> Scope.add_string
               (float_str
               ^ (if String.contains float_str '.' then "" else ".")
               ^ " ")
      | _ -> assert false)
  | Member s -> ("", vars) |> Scope.add_string @@ visit_struct_expr ast
  | Call { callee; args } -> (
      match List.length args with
      | 0 ->
          ("", vars)
          |> Scope.extend ~f:(visit_expr callee)
          |> Scope.add_string "();"
      | _ ->
          ("", vars) |> Scope.add_string "("
          |> Scope.extend ~f:(visit_expr callee)
          |> (fun s ->
               List.fold ~init:s
                 ~f:(fun s arg ->
                   Scope.aggregate s @@ visit_expr arg @@ Scope.get_vars s)
                 args)
          |> Scope.add_string ")")
  | _ ->
      Clang.Printer.expr Format.std_formatter ast;
      ("", vars)

let parse (source : string) : string =
  let ast = Clang.Ast.parse_string source in
  Scope.get_string
    (List.fold ~init:Scope.empty
       ~f:(fun s item ->
         Scope.aggregate s @@ visit_decl item @@ Scope.get_vars s)
       ast.desc.items)
