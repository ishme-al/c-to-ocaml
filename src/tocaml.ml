open Core
open Lib
  
let read =
  Command.Arg_type.create (fun filename ->
    match filename with
    | "-" -> In_channel.(input_all stdin)
    | _ -> In_channel.read_all filename)

let write =
  Command.Arg_type.create (fun filename ->
    match filename with
    | "-" -> Out_channel.stdout
    | _ -> Out_channel.create filename)

let command =
  Command.basic
    ~summary:"Transpile c to ocaml code"
    ~readme:(fun () -> "input-file: `-` for stdin\noutput-file: `-` for stdout")
    (let%map_open.Command
      watch = flag "-w" no_arg ~doc:"watch mode"
      and input = anon ("[input-file]" %: read)
      and output = anon ("[output-file]" %: write)
     in
     fun () ->
       if watch 
       then failwith "Not implemented"
       else Out_channel.output_string output input)

let () = Command_unix.run ~version:"0.1" ~build_info:"not sure what this is" command
