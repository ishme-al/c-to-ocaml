open Clang
let getnthdecl (filename:string) (n:int) =
  let tree = Clang.Ast.parse_file filename in
  let statementList = tree.desc.items in
  List.nth_exn statementList n

let decoupleFuncBody (functions:Clang.Decl.t) =
  match functions.desc with 
  | Function function_decl  -> Option.value_exn function_decl.body

let getNthFunc (filename:string) (n:int) =
  let tree = Clang.Ast.parse_file filename in
  let declList = tree.desc.items in
  let nthdecl = List.nth_exn declList n in
  match nthdecl.desc with 
  | Function function_decl -> Option.value_exn function_decl.body

let getNthStruct (filename:string) (n:int) =
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


let getnthFromMain (filename: string) (n:int) = 
  let tree = Clang.Ast.parse_file filename in
  let declList = tree.desc.items in
  let nthdecl = List.nth_exn declList 0 in
  let main = match nthdecl.desc with 
  | Function function_decl -> Option.value_exn function_decl.body in
  getnthCompoundLists main n

let viewAst (filename:string) = 
  let tree = Clang.Ast.parse_file filename in
  tree.desc.items


