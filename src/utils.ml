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
      | _ -> failwith "handle others later")
    (* will refactor into two helpers later, but focused on functionality instead of digging through documentation to find appropriate record equivalent for now*)
  | Ast.Elaborated structType ->
    (match structType.named_type with 
     | {desc=record;_} -> 
       (match record with 
        | Ast.Record recordObject-> 
          (match recordObject.name with
           | IdentifierName myName ->
             myName
           | _ -> failwith "handle others later" )
        | _ -> failwith "handle others later")
    )
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
  | LT -> "<"
  | GT -> ">"
  | EQ -> "="
  | Assign -> "="
  | Mul -> "*"
  | Div -> "/"
  | _ -> failwith "handle others later"
