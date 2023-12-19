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

(* return the string representation of a binary operator of the appropriate type*)
val parse_binary_operator : Clang.Ast.binary_operator_kind -> string -> string

(* returns true if the binary operator is logical (&&, ||), otherwise false *)
val is_logical_operator : Clang.Ast.binary_operator_kind -> bool

(* returns the string representation of a logical operator *)
val parse_logical_operator : Clang.Ast.binary_operator_kind -> string

(* returns true if type is of constant array, otherwise false *)
val is_array_type : Clang.Ast.qual_type -> bool

(* returns the string representation of the type of an array element *)
val get_array_type : Clang.Ast.qual_type -> string

(* return the size of a constant array *)
val get_array_size : Clang.Ast.qual_type -> int

(* returns the reference name of an array *)
val get_array_name : Clang.Ast.expr -> string

(* extract the index of the array element being accessed *)
val get_array_index : Clang.Ast.expr -> string

(* return true if the expression involves an array subscript operation *)
val is_array_subscript : Clang.Ast.expr -> bool

(* function to handle parsing empty variable initialization *)
val visit_empty_init :
  Clang.Ast.var_decl_desc ->
  string Scope.VarMap.t ->
  (string * string) list Scope.VarMap.t ->
  Scope.Scope.t

(* function to handle parsing struct declarations *)
val visit_struct_decl :
  Clang.Ast.record_decl ->
  string Scope.VarMap.t ->
  (string * string) list Scope.VarMap.t ->
  Scope.Scope.t
