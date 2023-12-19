val capitalize_first_letter : string -> string
val parse_qual_type : Clang.Ast.qual_type -> string
val parse_default_value : string -> string

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

