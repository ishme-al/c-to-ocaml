(* a variable counts as mutated when an assignment occurs and the variable was not declared in the scope of the function *)
open Clang
open Core

[@@@ocaml.warning "-26"]

let get_decl_names (ast : Ast.decl) : string =
  match ast.desc with
  | Function function_decl -> (
      match function_decl.name with
      | IdentifierName name -> name
      | _ -> assert false)
  | Var var_decl -> var_decl.var_name
  | RecordDecl struct_decl -> struct_decl.name
  (* | Field { name; qual_type; _ } ->
      Scope.add_string
        (name ^ ": " ^ parse_qual_type qual_type ^ "; ")
        ("", vars, types) *)
  | EmptyDecl -> ""
  | _ ->
    Clang.Printer.decl Format.std_formatter ast;
    ""
let get_expr_names (ast : Ast.expr): string = 
  match ast.desc with
  | DeclRef d ->(
      match d.name with
      | IdentifierName name -> name
      | _ -> assert false )
  | Member s ->
    let tempStruct = Option.value_exn s.base in
    let name =
      match tempStruct.desc with
      | DeclRef d -> (
          match d.name with IdentifierName name -> name 
          | _ -> assert false)
      | _ -> failwith "should never occur - struct name"
    in
    let field = s.field in
    let fieldName =
      match field with
      | FieldName f -> (
          match f.desc.name with
          | IdentifierName i -> i
          | _ -> failwith "should never occur -field")
      | _ -> failwith "should never occur -field2"
    in
    name ^ "." ^ fieldName
  | _ -> failwith "uh-oh in get_expr_name" 


let rec collect_from_stmt (stmt : Ast.stmt) (muts : string list)
    (inits : string list) : string list * string list =
  match stmt.desc with
  | Compound stmt_list ->
    List.fold ~init:(muts, inits)
      ~f:(fun acc stmt ->
          let m, i = acc in
          collect_from_stmt stmt m i)
      stmt_list
  | Decl decl_list ->
    List.fold ~init:(muts, inits)
      ~f:(fun acc decl ->
          let m, i = acc in
          collect_from_decl decl m i)
      decl_list
  | Expr expr -> collect_from_expr expr muts inits
  | If { then_branch; else_branch; _ } -> (
      let muts_then, inits_then = collect_from_stmt then_branch muts inits in
      match else_branch with
      | Some e -> collect_from_stmt e muts_then inits_then
      | None -> (muts_then, inits_then)
    )
  (* we only to return the variable mutated within the scope of the for loop, everything else can be modified in the loop using decl*)
  (* pass in initial value if for loop, pass in variables value if while loop*)
  (* init is Some if for loop has initialization, None if not*)
  (* don't know what condition variable is *)
  (* cond can be transated similar to if?*)
  (* body can be trasnlated as another compound*)
  (**)
  | For { init; body; inc; _ } -> (
      let muts_init, inits_init = match init with 
        | Some e -> collect_from_stmt e muts inits
        | None -> (muts, inits) in
      let muts_inc, inits_inc = match inc with 
        | Some e -> collect_from_stmt e muts_init inits_init
        | None -> (muts_init, inits_init) in
      let muts_body, inits_body = collect_from_stmt body muts_inc inits_inc in 
      (muts_body, inits_body)
      (* collect all variable previously mutated in body*)
      (* if a variable is declared inside, we should redeclare inside every time, so don't need to keep in scope*)
      (* if a variable is not declared inside body but then mutated, we need to pass it in as input and output of every iteration!*)
      (* if any variable is initialized, it is not mutated*)
      (* if a variable is in the condition, if it is declared in scope, not needed as intput/output, if it is o*)
    )
  | While { body; _} -> (
      let muts_body, inits_body = collect_from_stmt body muts inits in 
      (muts_body, inits_body)
      (* collect all variable previously mutated in body*)
      (* if a variable is declared inside, we should redeclare inside every time, so don't need to keep in scope*)
      (* if a variable is not declared inside body but then mutated, we need to pass it in as input and output of every iteration!*)
      (* if any variable is initialized, it is not mutated*)
      (* if a variable is in the condition, if it is declared in scope, not needed as intput/output, if it is o*)
    )
  | Break -> (muts, inits)
  | Return _ -> ([], inits)
  | _ -> failwith "uhoh in collect_from_stmt"

and collect_from_decl (decl : Ast.decl) (muts : string list)
    (inits : string list) : string list * string list =
  match decl.desc with
  | Var var_decl -> (muts, var_decl.var_name :: inits)
  | _ -> failwith "uhoh in collect_from_decl"

and collect_from_expr (expr : Ast.expr) (muts : string list)
    (inits : string list) : string list * string list =
  match expr.desc with
  | BinaryOperator { lhs; kind; _ } -> (
      match kind with
      | Assign -> collect_from_expr lhs muts inits
      | _ -> (muts, inits))
  | UnaryOperator {kind; operand; _} -> (
      match kind with 
      | PostInc ->
        collect_from_expr operand muts inits
      | PostDec ->
        collect_from_expr operand muts inits
      | _ -> (muts, inits)
    )
  | DeclRef d ->
    let name =
      match d.name with IdentifierName name -> name | _ -> assert false
    in
    if
      List.mem inits name ~equal:String.equal
      || List.mem muts name ~equal:String.equal
    then (muts, inits)
    else (name :: muts, inits)
  
    | ArraySubscript {base; _} ->
      let name = get_expr_names base in
      if
        List.mem inits name ~equal:String.equal
        || List.mem muts name ~equal:String.equal
      then (muts, inits)
      else (name :: muts, inits)

  | Call _ -> (muts, inits)
  | IntegerLiteral _ -> (muts, inits)
  | _ -> failwith "uhoh in collect_from_expr"

let collect_mutated_vars (stmt : Ast.stmt) (muts_init : string list) :
  string list =
  let muts, _ = collect_from_stmt stmt muts_init [] in
  muts


