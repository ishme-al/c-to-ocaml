open Clang

(* this file does not do anything directly related to translation, it is just in order to help visualize the ast's in order to understand how
   to use pattern matching to parse through them.
*)
(* since this file does not help with translation, and it just meant to paste into utop easily, there is no corresponding mli file. *)

(* gets the nth declaration in the file, aka the nth struct or the nth function, and there corresponding asts*)
let getnthdecl (filename:string) (n:int) =
  let tree = Clang.Ast.parse_file filename in
  let statementList = tree.desc.items in
  List.nth_exn statementList n

(* gets the body of a function ast (aka, removes info like the name of the function and just looks at statements within the function)*)
let decoupleFuncBody (functions:Clang.Decl.t) =
  match functions.desc with 
  | Function function_decl  -> Option.value_exn function_decl.body

(* gets the Nth declaration inside the file, but assumes that it is a function by default. If it is a struct instead, this will fail*)
let getNthFunc (filename:string) (n:int) =
  let tree = Clang.Ast.parse_file filename in
  let declList = tree.desc.items in
  let nthdecl = List.nth_exn declList n in
  match nthdecl.desc with 
  | Function function_decl -> Option.value_exn function_decl.body

(* gets the Nth declaration inside the file, but assumes that it is a struct by default. If it is a function instead, this will fail*)
let getNthStruct (filename:string) (n:int) =
  let tree = Clang.Ast.parse_file filename in
  let declList = tree.desc.items in
  let nthdecl = List.nth_exn declList n in
  match nthdecl.desc with 
  | RecordDecl function_decl -> function_decl

(* within a given function, gets the all the statements inside it*)
let getCompoundLists (decl: Clang.Stmt.t) = 
  match decl.desc with 
  | Compound statement_list -> statement_list

(* given a function, gets the ast for the nth statement inside, which could be an if, for loop, while loop, or variable declaration.*)
let getnthCompoundLists (decl: Clang.Stmt.t) n = 
  let temp = match decl.desc with 
  | Compound statement_list -> statement_list in
  List.nth_exn temp n

(* given a file, it assumes the first declaration inside is a function, namely main, and gets the ast of the nth statement inside that function*)
let getnthFromMain (filename: string) (n:int) = 
  let tree = Clang.Ast.parse_file filename in
  let declList = tree.desc.items in
  let nthdecl = List.nth_exn declList 0 in
  let main = match nthdecl.desc with 
  | Function function_decl -> Option.value_exn function_decl.body in
  getnthCompoundLists main n

(* views the ast of the c file.*)
let viewAst (filename:string) = 
  let tree = Clang.Ast.parse_file filename in
  tree.desc.items


