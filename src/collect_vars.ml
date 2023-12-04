(* a variable counts as mutated when an assignment occurs and the variable was not declared in the scope of the function *)
open Clang
open Core

let rec collect_from_stmt (stmt: Ast.stmt) (muts: string list) (inits: string list) : string list * string list =
  match stmt.desc with
  | Compound stmt_list ->
    List.fold ~init:(muts, inits) ~f:(fun acc stmt -> let (m, i) = acc in collect_from_stmt stmt m i) stmt_list 
  | Decl decl_list ->
    List.fold ~init:(muts, inits) ~f:(fun acc decl -> let (m, i) = acc in collect_from_decl decl m i) decl_list
  | Expr expr -> collect_from_expr expr muts inits
  | _ -> failwith "uhoh"

and collect_from_decl (decl: Ast.decl) (muts: string list) (inits: string list) : string list * string list =
  match decl.desc with
  | Var var_decl -> (muts, var_decl.var_name::inits)
  | _ -> failwith "uhoh"

and collect_from_expr (expr: Ast.expr) (muts: string list) (inits: string list) : string list * string list =
  match expr.desc with 
  | BinaryOperator {lhs; kind; _} -> (
    match kind with
    | Assign -> collect_from_expr lhs muts inits
    | _ -> (muts, inits)
  )
  | DeclRef d -> (
    let name = match d.name with | IdentifierName name -> name | _ -> assert false in
    if List.mem inits name ~equal:String.equal || List.mem muts name ~equal:String.equal 
      then (muts, inits) else (name::muts, inits)
  )
  | _ -> failwith "uhoh"

let collect_mutated_vars (stmt : Ast.stmt) (muts_init : string list) : string list =
  let (muts, _) = collect_from_stmt stmt muts_init [] in
  muts