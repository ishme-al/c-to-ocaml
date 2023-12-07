open Core
open Clang

[@@@ocaml.warning "-26"]

(* returns the OCaml equivalent type of a qual_type *)
let parse_qual_type (q : Ast.qual_type) : string =
  let temp = Stdio.printf "visit_qual_type \n" in
  match q.desc with
  | BuiltinType builtintype -> (
      match builtintype with
      | Long | Int -> "int"
      | UChar -> "char"
      | Char_S -> "char"
      | Float -> "float"
      | _ -> failwith "handle others later")

  | Ast.Elaborated structType ->
      let x = Stdio.printf "Occuring\n" in
      (match structType.named_type with 
      | {desc=record;_} -> 
        let y = Stdio.printf "Occuring2\n" in
        (match record with 
        | Ast.Record recordObject-> 
          let z = Stdio.printf "Occuring3\n" in
          (match recordObject.name with
          | IdentifierName myName ->
            let a = Stdio.printf "Occuring4\n" in
            let b = Stdio.printf "%s \n" myName in
            myName
          | _ -> failwith "handle others later" )
        | _ -> failwith "handle others later")
      (* | _ -> failwith "handle others later") *))
  | _ -> failwith "handle others later"

let parse_func_params (ast : Ast.function_decl) : string =
  let temp = Stdio.printf "visit_func params \n" in

  let parse_param (acc : string) (p : Ast.parameter) =
    acc ^ "(" ^ p.desc.name ^ " : " ^ parse_qual_type p.desc.qual_type ^ ") "
  in
  match ast.function_type.parameters with
  | Some params when params.variadic ->
      failwith "Variadic functions are not supported"
  | Some params -> List.fold ~f:parse_param params.non_variadic ~init:""
  | None -> ""

let parse_func_return_type (ast : Ast.function_decl) : string =
  let temp = Stdio.printf "visit_parse_func_return\n" in

  parse_qual_type ast.function_type.result

(* TODO: how handle operations on types other than ints? *)
let parse_binary_operator (op_kind : Ast.binary_operator_kind) : string =
  let temp = Stdio.printf "visit_binary\n" in

  match op_kind with
  | Add -> "+"
  | Sub -> "-"
  | LT -> "<"
  | GT -> ">"
  | Assign -> "="
  | Mul -> "*"
  | Div -> "/"
  | _ -> failwith "handle others later"

(* TODO: how to handle return in main function?? *)
let rec visit_stmt (ast : Ast.stmt) : string =
  let temp = Stdio.printf "visit_stment\n" in

  match ast.desc with
  | Compound stmt_list ->
      List.fold ~init:"" ~f:(fun s stmt -> s ^ visit_stmt stmt) stmt_list
  | Decl decl_list ->
      List.fold ~init:"" ~f:(fun s decl -> s ^ visit_decl decl) decl_list
  | Expr expr -> visit_expr expr
  | If { cond; then_branch; else_branch; _ } ->
      visit_if_stmt cond then_branch else_branch
      (* let else_string =
        match else_branch with
        | Some _ -> "else \n" ^ visit_stmt (Option.value_exn else_branch)
        | None -> ""
      in
      "if " ^ visit_expr cond ^ " then \n" ^ visit_stmt then_branch
      ^ else_string *)
  | Return (Some ret_expr) -> visit_expr ret_expr
  | Return None -> failwith "uhoh"
  | _ ->
      Clang.Printer.stmt Format.std_formatter ast;
      ""

and visit_if_stmt (cond : Ast.expr) (then_branch : Ast.stmt)
    (else_branch : Ast.stmt option) : string =

  let temp = Stdio.printf "visit_if\n" in
  let mutated =
    Collect_vars.collect_mutated_vars then_branch [] |> fun l ->
    match else_branch with
    | Some e -> Collect_vars.collect_mutated_vars e l
    | None -> l
  in
  let return_str = " (" ^ String.concat ~sep:"," mutated ^ ") " in
  let else_str =
    match else_branch with
    | Some e -> "else " ^ visit_stmt e ^ return_str
    | None -> ""
  in
  "let " ^ return_str ^ " = if " ^ visit_expr cond ^ " then "
  ^ visit_stmt then_branch ^ return_str ^ else_str ^ " in\n"

and visit_function_decl (ast : Ast.function_decl) : string =
  let temp = Stdio.printf "visit_function_decl\n" in
  match ast.name with
  | IdentifierName "main" ->
      "let () =\n" ^ visit_stmt (Option.value_exn ast.body) (* TODO: FIX *)
  | IdentifierName name ->
      "let " ^ name ^ " " ^ parse_func_params ast ^ ": "
      ^ parse_func_return_type ast ^ " = \n"
      ^ visit_stmt (Option.value_exn ast.body)
  | _ -> failwith "failure in visit_function_decl"

and visit_struct_decl (ast : Ast.record_decl ) : string = 
  let name = ast.name in
  "type " ^ name ^ " = { " ^ (List.fold ~init:"" ~f:(fun s item -> s ^ visit_decl item) ast.fields) ^ "} "  
  
(* and visit_field_decl (ast : Ast.field) : string = 
  let name = 
    match ast.name with   
  | IdentifierName fieldName -> fieldName in   
  name ^ ": " ^  parse_qual_type ast.qual_type ^ "; " *)

and visit_decl (ast : Ast.decl) : string =
  let temp = Stdio.printf "visit_decl\n" in
  match ast.desc with
  | Function function_decl -> 
    let temp2 = visit_function_decl function_decl in
    let temp3 = Stdio.printf "%s\n" temp2 in
    temp2
  | Var var_decl -> (
      match var_decl.var_init with
      | Some var_init ->
          let temp2 = "let " ^ var_decl.var_name ^ " : "
          ^ parse_qual_type var_decl.var_type
          ^ " = " ^ visit_expr var_init ^ " in\n" in
          let temp3 = Stdio.printf "%s\n" temp2 in
          temp2
      | None -> "")

  | RecordDecl struct_decl ->  
          let temp2 = visit_struct_decl struct_decl in
          let temp3 = Stdio.printf "%s\n" temp2 in
          temp2

  | Field { name; qual_type; _} ->       
      let temp2 = name ^ ": " ^  parse_qual_type qual_type ^ "; " in
      let temp3 = Stdio.printf "%s\n" temp2 in
      temp2
  (* | Ast.Member struct_pieces ->
      let a = Stdio.printf "matched here pog" in
      "" *)
  | _ ->

     let a = Stdio.printf "error here" in
      Clang.Printer.decl Format.std_formatter ast;
      ""

and visit_expr (ast : Ast.expr) : string =
  let temp = Stdio.printf "visit_expr\n" in
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
  | Ast.Member s -> (
      let tempStruct = Option.value_exn s.base in
      let name = match tempStruct.desc with 
      | DeclRef d -> (
          match d.name with 
          | IdentifierName name -> name
          | _ -> assert false
        ) 
      | _ -> failwith "handle other cases later"
      in
      let field = s.field in
      let fieldName =
        match field with 
        | FieldName f -> 
          (match f.desc.name with 
          | IdentifierName i -> i
          | _ -> failwith "handle edge case later" )
        | _ -> failwith "handle other cases later" in 
        name ^ "." ^ fieldName ^ " "   
  )
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
