open Core
open Ocamlformat_lib

let format (input_name : string) (output_file : string) (source : string) : string =
  (* print_endline source; *)
  match
    Conf.default |> Translation_unit.parse_and_format Syntax.Use_file 
                      ~output_file ~input_name ~source
  with
  | Ok formatted ->
      formatted
  | Error e ->
    Translation_unit.Error.print Format.err_formatter e; exit 1

let read (filename : string) =
    match filename with
    | "-" -> In_channel.(input_all stdin) |> Clang.Ast.parse_string
    | _ -> Clang.Ast.parse_file filename

let write (filename : string) (out : string) =
      match filename with
      | "-" -> Out_channel.print_string out
      | _ -> Out_channel.write_all filename ~data:out

let command =
  Command.basic
    ~summary:"Transpile c to ocaml code"
    ~readme:(fun () -> "input-file: `-` for stdin\noutput-file: `-` for stdout")
    (let%map_open.Command
      input = anon ("[input-file]" %: string)
     and output = anon ("[output-file]" %: string)
     in
       fun () -> read input |> Lib.parse |> format input output |> write output)

let () = Command_unix.run ~version:"0.1" ~build_info:"not sure what this is" command
