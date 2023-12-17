val capitalize_first_letter : string -> string
val parse_qual_type : Clang.Ast.qual_type -> string

val parse_func_params :
  Clang.Ast.function_decl ->
  string Scope.VarMap.t ->
  (string * string) list Scope.VarMap.t ->
  Scope.Scope.t

val parse_func_return_type : Clang.Ast.function_decl -> string

val parse_struct_field :
  Clang.Ast.decl ->
  string ->
  string Scope.VarMap.t ->
  (string * string) list Scope.VarMap.t ->
  Scope.Scope.t

val parse_struct_expr : Clang.Ast.expr -> string
val parse_op_type : Clang.Ast.expr -> string Scope.VarMap.t -> string
val parse_binary_operator : Clang.Ast.binary_operator_kind -> string -> string
