(* capitalizes the first character in a string *)
val capitalize_first_letter : string -> string

(* return the string representing a qual_type *)
val parse_qual_type : Clang.Ast.qual_type -> string

(* returns default values (0.0, 0, and ' ') for float, int, and char *)
val parse_default_value : string -> string

(* returns a scope with function parameters stringified and added to vars *)
val parse_func_params :
  Clang.Ast.function_decl ->
  string Scope.VarMap.t ->
  (string * string) list Scope.VarMap.t ->
  Scope.Scope.t

(* returns a string representing the return type of a function*)
val parse_func_return_type : Clang.Ast.function_decl -> string

(* parses a single field (name and type) from a struct decl *)
val parse_struct_field :
  Clang.Ast.decl ->
  string ->
  string Scope.VarMap.t ->
  (string * string) list Scope.VarMap.t ->
  Scope.Scope.t

(* parse a struct expression (accessing the field for a struct) *)
val parse_struct_expr : Clang.Ast.expr -> string

(* determine the type of an operator based on the operand type *)
val parse_op_type : Clang.Ast.expr -> string Scope.VarMap.t -> string

(* return the string representation of a binary operator *)
val parse_binary_operator : Clang.Ast.binary_operator_kind -> string -> string
val is_logical_operator : Clang.Ast.binary_operator_kind -> bool
val parse_logical_operator : Clang.Ast.binary_operator_kind -> string
val is_array_type : Clang.Ast.qual_type -> bool
val get_array_type : Clang.Ast.qual_type -> string
val get_array_size : Clang.Ast.qual_type -> int
val get_array_name : Clang.Ast.expr -> string
val get_array_index : Clang.Ast.expr -> string
val is_array_subscript : Clang.Ast.expr -> bool

val visit_empty_init :
  Clang.Ast.var_decl_desc ->
  string Scope.VarMap.t ->
  (string * string) list Scope.VarMap.t ->
  Scope.Scope.t

val visit_struct_decl :
  Clang.Ast.record_decl ->
  string Scope.VarMap.t ->
  (string * string) list Scope.VarMap.t ->
  Scope.Scope.t
(*
tree
   let tree = Clang.Ast.parse_file "tests/source/if.c";;
    let tree2 = tree.desc.items;;   
   let tree3 =List.nth_exn tree2 0;;
   let tree4 = match tree3.desc with Function function_decl  -> function_decl;;
let tree5 = Option.value_exn tree4.body;;
 let tree6 = tree5.desc;;
  let tree7 = match tree6 with Compound stment_list -> stment_list;;
  let tree8 = List.nth_exn tree7 2;;
  collect_mutated_vars tree8 [];;
*)

(*
let getnthdecl filename n =
  let tree = Clang.Ast.parse_file filename in
  let statementList = tree.desc.items in
  List.nth_exn statementList n

let decoupleFuncBody (functions:Clang.Decl.t) =
  match functions.desc with 
  | Function function_decl  -> Option.value_exn function_decl.body

let getNthFunc filename n =
  let tree = Clang.Ast.parse_file filename in
  let declList = tree.desc.items in
  let nthdecl = List.nth_exn declList n in
  match nthdecl.desc with 
  | Function function_decl -> Option.value_exn function_decl.body

let getNthStruct filename n =
  let tree = Clang.Ast.parse_file filename in
  let declList = tree.desc.items in
  let nthdecl = List.nth_exn declList n in
  match nthdecl.desc with 
  | RecordDecl function_decl -> function_decl

let getCompoundLists (decl: Clang.Stmt.t) = 
  match decl.desc with 
  | Compound statement_list -> statement_list

let getnthCompoundLists (decl: Clang.Stmt.t) n = 
  let temp = match decl.desc with 
  | Compound statement_list -> statement_list in
  List.nth_exn temp n

let getnthFromMain filename n = 
  let tree = Clang.Ast.parse_file filename in
  let declList = tree.desc.items in
  let nthdecl = List.nth_exn declList 0 in
  let main = match nthdecl.desc with 
  | Function function_decl -> Option.value_exn function_decl.body in
  getnthCompoundLists main n

*)
