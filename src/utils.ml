open Clang
open Core
open Scope

[@@@warning "-27"]

(* takes a string and capitalizes its first letter, used to turn int data data into Int Module *)
let capitalize_first_letter str =
  match String.length str with
  | 0 -> str (* Empty string, nothing to capitalize *)
  | _ ->
      String.concat ~sep:""
        [
          String.capitalize (String.sub str ~pos:0 ~len:1);
          String.sub str ~pos:1 ~len:(String.length str - 1);
        ]

(* returns the OCaml equivalent type of a qual_type *)
let rec parse_qual_type (q : Ast.qual_type) : string =
  match q.desc with
  | BuiltinType builtintype -> (
      match builtintype with
      | Long | ULong | Short | UShort | Int | UInt | LongLong | ULongLong ->
          "int"
      | UChar | Char_S -> "char"
      | Float | Double | LongDouble -> "float"
      | Void -> "unit"
      | _ -> failwith "Unsupported BuiltInType")
  | Elaborated struct_type -> (
      match struct_type.named_type with
      | { desc = record; _ } -> (
          match record with
          | Record record_object -> (
              match record_object.name with
              | IdentifierName name -> name
              | _ -> assert false)
          | _ -> assert false))
  | ConstantArray { element; _ } -> parse_qual_type element ^ " list"
  | _ -> failwith "Unsupported QualType"
(*gets defaults value of our three supported types. *)
let parse_default_value (val_type : string) : string =
  match val_type with
  | "int" -> "0"
  | "float" -> "0.0"
  | "char" -> "' '"
  | _ -> failwith @@ "Unsupported type " ^ val_type ^ ": unknown default value"

(* returns true if is an array*)
let is_array_type (q : Ast.qual_type) : bool =
  match q.desc with ConstantArray { element; _ } -> true | _ -> false

let get_array_type (q : Ast.qual_type) : string =
  match q.desc with
  | ConstantArray { element; _ } -> parse_qual_type element
  | _ -> assert false

let get_array_size (q : Ast.qual_type) : int =
  match q.desc with ConstantArray { size; _ } -> size | _ -> assert false

let is_array_subscript (q : Ast.expr) : bool =
  match q.desc with ArraySubscript _ -> true | _ -> false

let get_array_name (q : Ast.expr) : string =
  match q.desc with
  | ArraySubscript { base; _ } -> Collect_vars.get_expr_names base
  | _ -> assert false

let get_array_index (q : Ast.expr) : string =
  match q.desc with
  | ArraySubscript { index; _ } -> (
      match index.desc with
      | IntegerLiteral i -> (
          match i with Int value -> string_of_int value | _ -> assert false)
      | _ -> Collect_vars.get_expr_names index)
  | _ -> assert false

let parse_func_params (ast : Ast.function_decl) (vars : string VarMap.t)
    (types : (string * string) list VarMap.t) : Scope.t =
  let parse_param (acc : Scope.t) (p : Ast.parameter) : Scope.t =
    let qual_type = parse_qual_type p.desc.qual_type in
    match Scope.get_type types qual_type with
    | None ->
        acc
        |> Scope.add_var p.desc.name qual_type
        |> Scope.add_string ("(" ^ p.desc.name ^ " : " ^ qual_type ^ ") ")
    | Some list ->
        List.fold
          ~f:(fun acc (var, typ) ->
            Scope.add_var (p.desc.name ^ "." ^ var) typ acc)
          ~init:acc list
        |> Scope.add_string ("(" ^ p.desc.name ^ " : " ^ qual_type ^ ") ")
  in
  match ast.function_type.parameters with
  | Some params when params.variadic ->
      failwith "Variadic functions are not supported"
  | Some params ->
      List.fold ~f:parse_param params.non_variadic ~init:("", vars, types)
  | None -> ("()", vars, types)

let parse_func_return_type (ast : Ast.function_decl) : string =
  parse_qual_type ast.function_type.result

let parse_struct_field (ast : Ast.decl) (struct_name : string)
    (vars : string VarMap.t) (types : (string * string) list VarMap.t) : Scope.t
    =
  match ast.desc with
  | Field { name; qual_type; _ } ->
      ("", vars, types)
      |> Scope.add_type struct_name (name, parse_qual_type qual_type)
      |> Scope.add_string (name ^ ": " ^ parse_qual_type qual_type ^ "; ")
  | _ -> assert false

let parse_struct_expr (ast : Ast.expr) : string =
  match ast.desc with
  | Member s ->
      let tempStruct = Option.value_exn s.base in
      let name =
        match tempStruct.desc with
        | DeclRef d -> (
            match d.name with IdentifierName name -> name | _ -> assert false)
        | _ -> assert false
      in
      let field = s.field in
      let fieldName =
        match field with
        | FieldName f -> (
            match f.desc.name with IdentifierName i -> i | _ -> assert false)
        | _ -> assert false
      in
      name ^ "." ^ fieldName ^ " "
  | _ -> failwith "Error parsing struct expression"

let remove_list_suffix (list_type : string) : string =
  String.sub list_type ~pos:0 ~len:(String.length list_type - 5)

let parse_op_type (expr : Ast.expr) (vars : string VarMap.t) : string =
  match expr.desc with
  | DeclRef d -> (
      match d.name with
      | IdentifierName name ->
          Scope.get_var vars name |> String.strip |> capitalize_first_letter
      | _ -> assert false)
  | Member m ->
      parse_struct_expr expr |> String.strip |> Scope.get_var vars
      |> capitalize_first_letter
  | IntegerLiteral _ -> "Int"
  | FloatingLiteral _ -> "Float"
  | ArraySubscript _ ->
      let name = get_array_name expr in
      Scope.get_var vars name |> String.strip |> capitalize_first_letter
      |> remove_list_suffix
  | _ -> failwith "Unsupported operation type"

let parse_binary_operator (op_kind : Ast.binary_operator_kind)
    (var_type : string) : string =
  let op =
    match op_kind with
    | Add -> "+"
    | Sub -> "-"
    | LT -> "<"
    | LE -> "<="
    | GT -> ">"
    | GE -> ">="
    | EQ -> "="
    | NE -> "<>"
    | Mul -> "*"
    | Div -> "/"
    | _ -> failwith "Unsupported binary operator"
  in
  var_type ^ ".( " ^ op ^ " )"

let is_logical_operator (op_kind : Ast.binary_operator_kind) : bool =
  match op_kind with LAnd | LOr -> true | _ -> false

let parse_logical_operator (op_kind : Ast.binary_operator_kind) : string =
  match op_kind with
  | LAnd -> "&&"
  | LOr -> "||"
  | _ -> failwith "Unsupported logical operator"

let visit_empty_init (var_decl : Clang.Ast.var_decl_desc)
    (vars : string VarMap.t) (types : (string * string) list VarMap.t) : Scope.t
    =
  let var_name = var_decl.var_name in
  let var_type_name = parse_qual_type var_decl.var_type in
  if is_array_type var_decl.var_type then
    let n = string_of_int (get_array_size var_decl.var_type) in
    ("", vars, types)
    |> Scope.add_var var_name var_type_name
    |> Scope.add_string @@ "let " ^ var_name ^ " : " ^ var_type_name
       ^ " = List.init " ^ n ^ " ~f:(fun _ -> "
       ^ parse_default_value (get_array_type var_decl.var_type)
       ^ ") in \n"
  else ("", vars, types) |> Scope.add_var var_name var_type_name

let visit_struct_decl (ast : Ast.record_decl) (vars : string VarMap.t)
    (types : (string * string) list VarMap.t) : Scope.t =
  ("", vars, types)
  |> Scope.add_string @@ "type " ^ ast.name ^ " = { "
  |> (fun s ->
       List.fold ~init:s
         ~f:(fun s item ->
           Scope.aggregate s
           @@ parse_struct_field item ast.name (Scope.get_vars s)
                (Scope.get_types s))
         ast.fields)
  |> Scope.add_string " } "
