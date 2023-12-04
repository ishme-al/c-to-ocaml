open Core
open Ocamlformat_lib

let read =
  Command.Arg_type.create (fun filename ->
      match filename with
      | "-" -> In_channel.(input_all stdin) |> Clang.Ast.parse_string
      | _ -> Clang.Ast.parse_file filename)

let write =
  Command.Arg_type.create (fun filename ->
      match filename with
      | "-" -> Out_channel.print_string
      | _ -> fun data -> Out_channel.write_all filename ~data)

let format (source : string) : string =
  match
    Conf.default
    |> Translation_unit.parse_and_format Syntax.Use_file
         ~input_name:".translated.ml" ~source
  with
  | Ok formatted -> formatted
  | Error e ->
      (* helpful output for debugging *)
      Out_channel.write_all ".translated.ml" ~data:source;
      Translation_unit.Error.print Format.err_formatter e;
      Sys_unix.remove ".translated.ml";
      prerr_endline @@ ".translated.ml:\n" ^ source;
      exit 1

let command =
  Command.basic ~summary:"Transpile c to ocaml code"
    ~readme:(fun () -> "input-file: `-` for stdin\noutput-file: `-` for stdout")
    (let%map_open.Command input = anon ("[input-file]" %: read)
     and output = anon ("[output-file]" %: write) in
     fun () -> input |> Lib.parse |> format |> output)

let () =
  Command_unix.run ~version:"0.1" ~build_info:"not sure what this is" command
