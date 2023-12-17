open Clang
open Core
open Scope

[@@@warning "-27"]

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
let parse_qual_type (q : Ast.qual_type) : string =
  match q.desc with
  | BuiltinType builtintype -> (
      match builtintype with
      | Long | Int -> "int"
      | UChar -> "char"
      | Char_S -> "char"
      | Float -> "float"
      | Void -> "unit"
      | _ -> failwith "handle others later")
  (* will refactor into two helpers later, but focused on functionality instead of digging through documentation to find appropriate record equivalent for now*)
  | Elaborated struct_type -> (
      match struct_type.named_type with
      | { desc = record; _ } -> (
          match record with
          | Record record_object -> (
              match record_object.name with
              | IdentifierName name -> name
              | _ -> assert false)
          | _ -> failwith "handle others later"))
  | _ -> failwith "handle others later"

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
  | None -> ("", vars, types)

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
  | _ -> failwith "handle other cases later"

let parse_binary_operator (op_kind : Ast.binary_operator_kind)
    (var_type : string) : string =
  let op =
    match op_kind with
    | Add -> "+"
    | Sub -> "-"
    | LT -> "<"
    | GT -> ">"
    | EQ -> "="
    | Assign -> "="
    | Mul -> "*"
    | Div -> "/"
    | _ -> failwith "handle others later"
  in
  var_type ^ ".( " ^ op ^ " )"
