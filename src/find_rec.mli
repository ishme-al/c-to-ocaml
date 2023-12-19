(* traverses function ast; returns true if recursive, false otherwise *)
val find_rec_func : string -> Clang.Ast.stmt -> bool
