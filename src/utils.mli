val parse_qual_type : Clang.Ast.qual_type -> string
val parse_func_params : Clang.Ast.function_decl -> string
val parse_func_return_type : Clang.Ast.function_decl -> string
val parse_binary_operator : Clang.Ast.binary_operator_kind -> string
