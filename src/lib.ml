open Core
open Clang
open Utils
open Scope

[@@@ocaml.warning "-26"]
[@@@ocaml.warning "-27"]

(* visits a statement and outputs a parse for it. This includes combination of statements, for loops, if statements, while loopps, and more*)
let rec visit_stmt (ast : Ast.stmt) (func_name : string)
    (mutated_vars : string list) (vars : string VarMap.t)
    (types : (string * string) list VarMap.t) : Scope.t =
  match ast.desc with
  | Compound stmt_list ->
      List.fold ~init:("", vars, types)
        ~f:(fun s stmt ->
          Scope.aggregate s
          @@ visit_stmt stmt func_name mutated_vars (Scope.get_vars s)
               (Scope.get_types s))
        stmt_list
  | Decl decl_list ->
      List.fold ~init:("", vars, types)
        ~f:(fun s decl ->
          Scope.aggregate s
          @@ visit_decl decl mutated_vars (Scope.get_vars s) (Scope.get_types s))
        decl_list
  | Expr expr -> visit_expr expr mutated_vars vars types
  | If { cond; then_branch; else_branch; _ } ->
      ("", vars, types)
      |> Scope.new_level
           ~f:
             (visit_if_stmt cond then_branch else_branch func_name mutated_vars)
  | For _ ->
      ("", vars, types)
      |> Scope.new_level
           ~f:(visit_for_stmt ast ("for_" ^ func_name) mutated_vars)
  | While _ ->
      ("", vars, types)
      |> Scope.new_level
           ~f:(visit_while_stmt ast ("while_" ^ func_name) mutated_vars)
  | Return (Some ret_expr) -> (
      match func_name with
      | "main" ->
          ("", vars, types) |> Scope.add_string "exit("
          |> Scope.extend ~f:(visit_expr ret_expr mutated_vars)
          |> Scope.add_string ")\n"
      | _ ->
          ("", vars, types)
          |> Scope.extend ~f:(visit_expr ret_expr mutated_vars))
  | Break ->
      ("", vars, types)
      |> Scope.add_string
           (List.nth_exn mutated_vars (List.length mutated_vars - 1))
  | Return None -> ("", vars, types) |> Scope.add_string "()"
  | _ -> failwith "Unsupported statement type"

(* visits an if statment  ast and adds the ocaml translation back *)
and visit_if_stmt (cond : Ast.expr) (then_branch : Ast.stmt)
    (else_branch : Ast.stmt option) (func_name : string)
    (mutated_vars : string list) (vars : string VarMap.t)
    (types : (string * string) list VarMap.t) : Scope.t =
  let mutated =
    Collect_vars.collect_mutated_vars then_branch [] |> fun l ->
    match else_branch with
    | Some e -> Collect_vars.collect_mutated_vars e l
    | None -> l
  and else_str (vars : string VarMap.t)
      (types : (string * string) list VarMap.t) =
    match else_branch with
    | Some e -> visit_stmt e func_name mutated_vars vars types
    | None -> ("", vars, types)
  in
  match List.length mutated with
  | 0 ->
      ("", vars, types) |> Scope.add_string "if "
      |> Scope.extend ~f:(visit_expr cond mutated_vars)
      |> Scope.add_string " then "
      |> Scope.extend ~f:(visit_stmt then_branch func_name mutated_vars)
      |> Scope.add_string " else " |> Scope.extend ~f:else_str
      |> Scope.add_string "\n"
  | _ ->
      let return_str = " (" ^ String.concat ~sep:"," mutated ^ ") " in
      ("", vars, types)
      |> Scope.add_string @@ "let " ^ return_str ^ " = if "
      |> Scope.extend ~f:(visit_expr cond mutated_vars)
      |> Scope.add_string " then "
      |> Scope.extend ~f:(visit_stmt then_branch func_name mutated_vars)
      |> Scope.add_string @@ return_str ^ " else "
      |> Scope.extend ~f:else_str
      |> Scope.add_string @@ return_str ^ " in\n"

(* visits the for statement ast and adds the translated ocaml loop *)
and visit_for_stmt (ast : Ast.stmt) (func_name : string)
    (mutated_vars : string list) (vars : string VarMap.t)
    (types : (string * string) list VarMap.t) : Scope.t =
  match ast.desc with
  | For { cond; init; body; inc; _ } ->
      let mutated = Collect_vars.collect_mutated_vars ast [] in
      let allMutated =
        match List.length mutated with
        | 0 -> "()"
        | _ -> "(" ^ String.concat ~sep:"," mutated ^ ")"
      in
      let varName =
        match init with
        | Some e -> (
            match e.desc with
            | Decl decl_list ->
                List.fold ~init:[]
                  ~f:(fun sArray s -> Collect_vars.get_decl_names s :: sArray)
                  decl_list
            | _ -> assert false)
        | None -> []
      in
      let allVarNames =
        match List.length varName with
        | 0 -> "()"
        | _ -> "(" ^ String.concat ~sep:"," varName ^ ")"
      in
      let start = ("", vars, types) in
      let initStart =
        match init with
        | Some e ->
            Scope.extend start
              ~f:(visit_stmt e func_name (mutated_vars @ [ allMutated ]))
        | None -> start
      in
      Scope.add_string
        ("let rec " ^ func_name ^ allVarNames ^ allMutated ^ " = match ")
        initStart
      |> Scope.extend
           ~f:
             (visit_expr (Option.value_exn cond)
                (mutated_vars @ [ allMutated ]))
      |> Scope.add_string @@ " with | false -> "
      |> Scope.add_string @@ allMutated ^ " \n"
      |> Scope.add_string @@ " | true -> ("
      |> Scope.extend
           ~f:(visit_stmt body func_name (mutated_vars @ [ allMutated ]))
      |> Scope.extend
           ~f:
             (visit_stmt (Option.value_exn inc) func_name
                (mutated_vars @ [ allMutated ]))
      |> Scope.add_string @@ func_name ^ allVarNames ^ allMutated ^ " ) in \n"
      |> Scope.add_string @@ "let " ^ allMutated ^ " = " ^ func_name
         ^ allVarNames ^ allMutated ^ " in \n"
  | _ -> assert false

(* visits the while statement ast and adds the translated ocaml loop *)
and visit_while_stmt (ast : Ast.stmt) (func_name : string)
    (mutated_vars : string list) (vars : string VarMap.t)
    (types : (string * string) list VarMap.t) : Scope.t =
  match ast.desc with
  | While { cond; body; _ } ->
      let mutated = Collect_vars.collect_mutated_vars ast [] in
      let allMutated = "(" ^ String.concat ~sep:"," mutated ^ ")" in
      let pass_on_mutated = " ( " ^ allMutated ^ " ) " in
      ("", vars, types)
      |> Scope.add_string @@ "let rec " ^ func_name ^ allMutated ^ " = match  "
      |> Scope.extend ~f:(visit_expr cond (mutated_vars @ [ allMutated ]))
      |> Scope.add_string @@ " with | false -> "
      |> Scope.add_string @@ allMutated ^ "\n"
      |> Scope.add_string @@ " | true -> ( "
      |> Scope.extend
           ~f:(visit_stmt body func_name (mutated_vars @ [ allMutated ]))
      |> Scope.add_string @@ func_name ^ allMutated ^ " ) in \n"
      |> Scope.add_string @@ "let " ^ allMutated ^ " = " ^ func_name
         ^ allMutated ^ " in \n"
  | _ -> assert false

(* visits the function ast, and recursively every statement with in it, and adds the translated ocaml loop *)
and visit_function_decl (ast : Ast.function_decl) (mutated_vars : string list)
    (vars : string VarMap.t) (types : (string * string) list VarMap.t) : Scope.t
    =
  match ast.name with
  | IdentifierName "main" ->
      ("", vars, types)
      |> Scope.add_string "let () =\n"
      |> Scope.extend
           ~f:(visit_stmt (Option.value_exn ast.body) "main" mutated_vars)
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
      ("", vars, types)
      |> Scope.add_string (let_str ^ name ^ " ")
      |> Scope.extend ~f:(parse_func_params ast)
      |> Scope.add_string (return_str ^ " = \n")
      |> Scope.extend
           ~f:(visit_stmt (Option.value_exn ast.body) name mutated_vars)
  | _ -> assert false

(* visits the declaration  ast of a variable, function, or struct and translated it*)
and visit_decl (ast : Ast.decl) (mutated_vars : string list)
    (vars : string VarMap.t) (types : (string * string) list VarMap.t) : Scope.t
    =
  match ast.desc with
  | Function function_decl ->
      visit_function_decl function_decl mutated_vars vars types
  | Var var_decl -> (
      let var_type = parse_qual_type var_decl.var_type in
      match var_decl.var_init with
      | Some var_init ->
          ("", vars, types)
          |> Scope.add_var var_decl.var_name var_type
          |> Scope.add_string @@ "let " ^ var_decl.var_name ^ " : " ^ var_type
             ^ " = "
          |> Scope.extend
               ~f:
                 (visit_var_init var_init var_decl.var_name var_type
                    mutated_vars)
          |> Scope.add_string " in\n"
      | None -> visit_empty_init var_decl vars types)
  | RecordDecl struct_decl -> visit_struct_decl struct_decl vars types
  | EmptyDecl -> ("", vars, types)
  | _ -> failwith "Unsupported declaration type"

(* if variable is initialized to a value when declared, visits the corresponding ast and translates it, namely arrays here (see initlist)*)
and visit_var_init (ast : Ast.expr) (var_name : string) (var_type : string)
    (mutated_vars : string list) (vars : string VarMap.t)
    (types : (string * string) list VarMap.t) : Scope.t =
  match ast.desc with
  | InitList expr_list -> (
      match Scope.get_type types var_type with
      | Some struct_types ->
          ("", vars, types) |> Scope.add_string "{ "
          |> (fun s ->
               List.fold ~init:s ~f:(fun s item ->
                   let expr, (item_name, item_type) = item in
                   s
                   |> Scope.add_var (var_name ^ "." ^ item_name) item_type
                   |> Scope.add_string @@ item_name ^ " = "
                   |> Scope.extend ~f:(visit_expr expr mutated_vars)
                   |> Scope.add_string "; ")
               @@ List.zip_exn expr_list (List.rev struct_types))
          |> Scope.add_string " }"
      | None -> (
          match List.length expr_list with
          | 0 -> ("[]", vars, types)
          | _ ->
              ("", vars, types) |> Scope.add_string "["
              |> (fun s ->
                   List.fold ~init:s
                     ~f:(fun s item ->
                       Scope.aggregate s
                       @@ visit_expr item mutated_vars (Scope.get_vars s)
                            (Scope.get_types s)
                       |> Scope.add_string "; ")
                     expr_list)
              |> Scope.add_string "]"))
  | _ -> visit_expr ast mutated_vars vars types

(* translated an expression with a binary operattor, like equals (see Assign), +, - etc*)
and visit_binary_op_expr (lhs : Ast.expr) (rhs : Ast.expr)
    (kind : Ast.binary_operator_kind) (mutated_vars : string list)
    (vars : string VarMap.t) (types : (string * string) list VarMap.t) : Scope.t
    =
  match kind with
  | Assign -> (
      match is_array_subscript lhs with
      | true ->
          let name = get_array_name lhs in
          let index = get_array_index lhs in
          ("", vars, types)
          |> Scope.add_string @@ "let " ^ name ^ " = set_at_index " ^ name ^ " "
             ^ index ^ "( "
          |> Scope.extend ~f:(visit_expr rhs mutated_vars)
          |> Scope.add_string ") in\n"
      | false ->
          ("", vars, types) |> Scope.add_string "let "
          |> Scope.extend ~f:(visit_expr lhs mutated_vars)
          |> Scope.add_string " = "
          |> Scope.extend ~f:(visit_expr rhs mutated_vars)
          |> Scope.add_string " in\n")
  | _ when is_logical_operator kind ->
      ("", vars, types) |> Scope.add_string "("
      |> Scope.extend ~f:(visit_expr lhs mutated_vars)
      |> Scope.add_string ") "
      |> Scope.add_string (parse_logical_operator kind ^ " ")
      |> Scope.add_string "("
      |> Scope.extend ~f:(visit_expr rhs mutated_vars)
      |> Scope.add_string ")"
  | _ ->
      let op_type = parse_op_type lhs vars in
      ("", vars, types)
      |> Scope.add_string (parse_binary_operator kind op_type ^ " ")
      |> Scope.extend ~f:(visit_expr lhs mutated_vars)
      |> Scope.extend ~f:(visit_expr rhs mutated_vars)

(* adds translation of any unary operation, such as post++ and post-- *)
and visit_unary_op_expr (kind : Ast.unary_operator_kind) (operand : Ast.expr)
    (mutated_vars : string list) (vars : string VarMap.t)
    (types : (string * string) list VarMap.t) : Scope.t =
  match kind with
  | PostInc -> (
      match is_array_subscript operand with
      | true ->
          (* sepcial case for array)*)
          let name = get_array_name operand in
          let index = get_array_index operand in
          ("", vars, types)
          |> Scope.add_string @@ "let " ^ name ^ " = set_at_index " ^ name ^ " "
             ^ index ^ " (( List.nth_exn " ^ name ^ " " ^ index
             ^ " ) + 1 ) in\n"
      | false ->
          ("", vars, types) |> Scope.add_string "let "
          |> Scope.extend ~f:(visit_expr operand mutated_vars)
          |> Scope.add_string " = "
          |> Scope.extend ~f:(visit_expr operand mutated_vars)
          |> Scope.add_string " + 1 in\n")
  | PostDec -> (
      match is_array_subscript operand with
      | true ->
        (* special case for array)*)
          let name = get_array_name operand in
          let index = get_array_index operand in
          ("", vars, types)
          |> Scope.add_string @@ "let " ^ name ^ " = set_at_index " ^ name ^ " "
             ^ index ^ " (( List.nth_exn " ^ name ^ " " ^ index
             ^ " ) - 1 ) in\n"
      | false ->
          ("", vars, types) |> Scope.add_string "let "
          |> Scope.extend ~f:(visit_expr operand mutated_vars)
          |> Scope.add_string " = "
          |> Scope.extend ~f:(visit_expr operand mutated_vars)
          |> Scope.add_string " - 1 in\n")
  | _ -> failwith "Unsupported Unary Operator"

(* translates a custom function that was called*)
and visit_func_call (callee : Ast.expr) (args : Ast.expr list)
    (mutated_vars : string list) (vars : string VarMap.t)
    (types : (string * string) list VarMap.t) : Scope.t =
  let callee_name =
    String.strip @@ Scope.get_string
    @@ visit_expr callee mutated_vars vars types
  in
  match List.length args with
  | 0 ->
      ("", vars, types)
      |> Scope.extend ~f:(visit_expr callee mutated_vars)
      |> Scope.add_string "();"
  | _ ->
      let end_str = if String.equal callee_name "printf" then ";" else "" in
      ("", vars, types) |> Scope.add_string "("
      |> Scope.extend ~f:(visit_expr callee mutated_vars)
      |> (fun s ->
           List.fold ~init:s
             ~f:(fun s arg ->
               s |> Scope.add_string "("
               |> Scope.extend ~f:(visit_expr arg mutated_vars)
               |> Scope.add_string ") ")
             args)
      |> Scope.add_string @@ ")" ^ end_str

(* translates any expression, such as a unary operator, an array + indexing, variable expression, structs, and more*)
and visit_expr (ast : Ast.expr) (mutated_vars : string list)
    (vars : string VarMap.t) (types : (string * string) list VarMap.t) : Scope.t
    =
  match ast.desc with
  | BinaryOperator { lhs; rhs; kind } ->
      visit_binary_op_expr lhs rhs kind mutated_vars vars types
  | UnaryOperator { kind; operand; _ } ->
      visit_unary_op_expr kind operand mutated_vars vars types
  | ArraySubscript { base; index; _ } ->
      let name = Collect_vars.get_expr_names base in
      let stringIndex = get_array_index ast in
      ("", vars, types)
      |> Scope.add_string @@ "(List.nth_exn " ^ name ^ " " ^ stringIndex ^ ") "
  | DeclRef d -> (
      match d.name with
      | IdentifierName name -> ("", vars, types) |> Scope.add_string (name ^ " ")
      | _ -> assert false)
  | IntegerLiteral i -> (
      match i with
      | Int value ->
          ("", vars, types) |> Scope.add_string (Int.to_string value ^ " ")
      | _ -> assert false)
  | FloatingLiteral f -> (
      match f with
      | Float value ->
          let float_str = Float.to_string value in
          ("", vars, types)
          |> Scope.add_string
               (float_str
               ^ (if String.contains float_str '.' then "" else ".")
               ^ " ")
      | _ -> assert false)
  | CharacterLiteral { value; _ } ->
      ("", vars, types)
      |> Scope.add_string
           ("'" ^ (String.of_char @@ Char.of_int_exn value) ^ "' ")
  | StringLiteral { bytes; _ } ->
      ("", vars, types) |> Scope.add_string ("\"" ^ bytes ^ "\" ")
  | Member s -> ("", vars, types) |> Scope.add_string @@ parse_struct_expr ast
  | Call { callee; args } -> visit_func_call callee args mutated_vars vars types
  | _ -> failwith "Unsupported expression type"

(* parses through the given string, representing the c file*)
let parse (source : string) : string =
  let ast = Clang.Ast.parse_string source in
  let items =
    if
      Str.string_match
        (Str.regexp "#[ \\n\\t\\r]*include[ \\n\\t\\r]+<stdio\\.h>")
        source 0
    then
      List.drop ast.desc.items
        (List.length @@ (Clang.Ast.parse_string "#include <stdio.h>").desc.items)
    else ast.desc.items
  in
  Scope.get_string
    (List.fold ~init:Scope.empty
       ~f:(fun s item ->
         Scope.aggregate s
         @@ visit_decl item [] (Scope.get_vars s) (Scope.get_types s))
       items)

(* do not move this. its names conflicts with clangml *)
open Ocamlformat_lib

(* formats the resulting ocaml transpiled code using ocaml formatter.*)
let format (output : string) (source : string) : string option =
  (* .translated.ml is a temporary file for showing errors if the output is stdout *)
  let temp = String.equal "-" output in
  let output = if temp then ".translated.ml" else output in
  match
    Conf.default
    |> Translation_unit.parse_and_format Syntax.Use_file ~input_name:output
         ~source
  with
  | Ok formatted -> Some formatted
  | Error e ->
      (* write broken translation out *)
      Out_channel.write_all output ~data:source;
      Translation_unit.Error.print Format.err_formatter e;
      if temp then (
        (* delete temp file *)
        Sys_unix.remove ".translated.ml";
        prerr_endline @@ ".translated.ml:\n" ^ source);
      None
