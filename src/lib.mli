open Clang

val parse : Clang.Ast.translation_unit -> Out_channel.t -> unit

val visit_stmt : Ast.stmt -> Out_channel.t -> unit
val visit_function_decl : Ast.function_decl -> Out_channel.t -> unit
val visit_decl : Ast.decl -> Out_channel.t -> unit
(* many more of this ... *)
