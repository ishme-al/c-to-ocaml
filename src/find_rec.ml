open Clang

let rec find_in_stmt (func_name : string) (ast : Ast.stmt) : bool =
  match ast.desc with
  | Compound stmt_list -> List.exists (find_in_stmt func_name) stmt_list
  | Decl decl_list -> List.exists (find_in_decl func_name) decl_list
  | Expr expr -> find_in_expr func_name expr
  | If { then_branch; else_branch; _ } ->
      let in_else =
        match else_branch with
        | Some e -> find_in_stmt func_name e
        | None -> false
      in
      in_else || find_in_stmt func_name then_branch
  | Return (Some ret_expr) -> find_in_expr func_name ret_expr
  | _ -> false

and find_in_decl (func_name : string) (ast : Ast.decl) : bool =
  match ast.desc with
  | Var { var_init = Some init_expr; _ } -> find_in_expr func_name init_expr
  | _ -> false

and find_in_expr (func_name : string) (ast : Ast.expr) : bool =
  match ast.desc with
  | Call { callee; args } -> (
      match callee.desc with
      | DeclRef d -> (
          match d.name with
          | IdentifierName name when name = func_name -> true
          | _ -> List.exists (find_in_expr func_name) args)
      | _ -> List.exists (find_in_expr func_name) args)
  | _ -> false

let find_rec_func (func_name : string) (ast : Ast.stmt) : bool =
  find_in_stmt func_name ast
