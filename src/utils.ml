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
let rec parse_qual_type (q : Ast.qual_type) : string =
  match q.desc with
  | BuiltinType builtintype -> (
      match builtintype with
      | Long | Int -> "int"
      | UChar -> "char"
      | Char_S -> "char"
      | Float -> "float"
      | Void -> "unit"
      | _ -> failwith "Unsupported BuiltInType")
  (* will refactor into two helpers later, but focused on functionality instead of digging through documentation to find appropriate record equivalent for now*)
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

let parse_default_value (val_type: string) : string = 
  match val_type with
  | "int" -> "0"
  | "float" -> "0.0"
  | "char" -> "' '"
  | _ -> failwith @@ "Unsupported type " ^ val_type ^ ": unknown default value"

let is_array_type (q : Ast.qual_type) : bool =
  match q.desc with
  | ConstantArray { element; _ } -> true
  | _ -> false

let get_array_type (q : Ast.qual_type) : string =
  match q.desc with
  | ConstantArray { element; _ } -> parse_qual_type element
  | _ -> assert false

let get_array_size (q : Ast.qual_type) : int =
  match q.desc with
  | ConstantArray { size; _ } -> size
  | _ -> assert false

let is_array_subscript (q : Ast.expr) : bool =
  match q.desc with
  | ArraySubscript _ -> true
  | _ -> false

let get_array_name (q: Ast.expr): string = 
  match q.desc with 
  | ArraySubscript {base; _ } -> Collect_vars.get_expr_names base 
  | _ -> failwith "shouldn't occur"

let get_array_index (q: Ast.expr): string = 
  match q.desc with 
  | ArraySubscript {index; _} -> 
    (match index.desc with 
    | IntegerLiteral i -> (
      match i with
      | Int value ->
        string_of_int value
      | _ -> assert false)
    | _ -> Collect_vars.get_expr_names index )
  | _ -> failwith "shouldn't occur"


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
  (* | _ -> Clang.Printer.decl Format.std_formatter ast; Out_channel.flush stdout; assert false *)

let parse_struct_expr (ast : Ast.expr) : string =
  match ast.desc with
  | Member s ->
    let tempStruct = Option.value_exn s.base in
    let name =
      match tempStruct.desc with
      | DeclRef d -> (
          match d.name with IdentifierName name -> name | _ -> assert false)
      | _ -> failwith "should never occur - struct name"
    in
    let field = s.field in
    let fieldName =
      match field with
      | FieldName f -> (
          match f.desc.name with
          | IdentifierName i -> i
          | _ -> failwith "should never occur -field")
      | _ -> failwith "should never occur -field2"
    in
    name ^ "." ^ fieldName ^ " "
  | _ -> failwith "handle other cases later"

  let remove_list_suffix (list_type: string):string = 
    String.sub list_type ~pos:0 ~len:((String.length list_type) - 5)

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
  | ArraySubscript _ -> let name = get_array_name expr in
      Scope.get_var vars name |> String.strip |> capitalize_first_letter |> remove_list_suffix
  | _ -> failwith "handle other cases later - optype"


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
    (* TODO | LAnd -> "&&"
    | LOr -> "||" *)
    | Assign -> "="
    | Mul -> "*"
    | Div -> "/"
    | _ -> failwith "handle others later"
  in
  var_type ^ ".( " ^ op ^ " )"
