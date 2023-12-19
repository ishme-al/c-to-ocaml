open Core
open Fswatch

let read (filename : string) =
  match filename with
  | "-" -> In_channel.(input_all stdin)
  | _ -> In_channel.read_all filename

let write (filename : string) (data : string) : unit =
  match filename with
  | "-" ->
      Out_channel.output_string stdout data;
      Out_channel.flush stdout
  | _ -> Out_channel.write_all filename ~data

let transpile (input : string) (output : string) =
  input |> read |> Lib.parse |> Lib.format output
  |> Option.iter ~f:(fun data -> write output data)

let start input output =
  (* start -> transpile -> callback -> start *)
  let rec start () =
    transpile input output;
    let handle = init_session Monitor.System_default callback in
    add_path handle input;
    start_monitor handle
  and callback _ = start () in
  start () (* start an infinite loop *)

let command =
  Command.basic ~summary:"Transpile c to ocaml code"
    ~readme:(fun () -> "input-file: `-` for stdin\noutput-file: `-` for stdout")
    (let%map_open.Command watch = flag "-w" no_arg ~doc:"watch mode"
     and input = anon ("[input-file]" %: string)
     and output = anon ("[output-file]" %: string) in
     fun () ->
       if watch then
         match init_library () with
         | Status.FSW_OK -> start input output
         | err -> Printf.eprintf "%s\n" (Status.t_to_string err)
       else transpile input output)

let () =
  Command_unix.run ~version:"0.1" ~build_info:"not sure what this is" command
