(* main library function that will generate the translated code for a file *)
(* will iterate through all of the different declarations in the file, and call the visit decl function, which will translate that declartion
   on it*)
val parse : string -> string
val visualize_ast : Clang.Ast.translation_unit -> Out_channel.t -> unit

(* function to generate a translation of a statement in the ast (ex: int a = 4 is a statement) *)
(* will use pattern matching to determine the type of statement (ex: for loop, while loop, switch, assignment, etc) *)
(* will call the appropriate "visit" function to translate that type of statement*)
(* val visit_stmt : Ast.stmt -> Out_channel.t -> unit *)

(* translate for loop statements, by iteration through corresponding statement in the for loop as well *)
(* would look something like as follows:*)
(* val visit_for_stmt : Ast.For -> Out_channel.t -> unit *)

(* translate while loop statements, by iteration through corresponding statement in the while loop as well*)
(* would look something like as follows:*)
(* val visit_while_stmt : Ast.While -> Out_channel.t -> unit *)

(* ... Support for many different types of statements as time permits*)

(* function to generate a translation of a function in the ast *)
(* will use pattern matching to visit every statement inside the function *)
(* based on type of statement, will call the appropriate visit_statement function *)
(* val visit_function_decl : Ast.function_decl -> Out_channel.t -> unit *)

(*... support for different types of declarations, like structs as time permits, will have very similar logic*)

(* will generate a translation of any given declaration in the file *)
(* will use pattern matching to determine the specific type of declaration (ex: function declaration) and call the corresponding visit_function *)
(* val visit_decl : Ast.decl -> Out_channel.t -> unit *)

(* many more of this ... *)
