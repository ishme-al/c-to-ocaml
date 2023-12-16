open Clang
open Core

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
              | _ -> failwith "handle others later")
          | _ -> failwith "handle others later"))
  | _ -> failwith "handle others later"

let parse_func_return_type (ast : Ast.function_decl) : string =
  parse_qual_type ast.function_type.result

(* TODO: how handle operations on types other than ints? *)
let parse_binary_operator (op_kind : Ast.binary_operator_kind)
    (var_type : string) : string =
  let op = match op_kind with
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

let capitalize_first_letter str =
  match String.length str with
  | 0 -> str (* Empty string, nothing to capitalize *)
  | _ ->
      String.concat ~sep:""
        [
          String.capitalize (String.sub str ~pos:0 ~len:1);
          String.sub str ~pos:1 ~len:(String.length str - 1);
        ]
