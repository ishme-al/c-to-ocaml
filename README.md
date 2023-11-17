# tocaml
```
Transpile c to ocaml code

  tocaml.exe [input-file] [output-file]

input-file: `-` for stdin
output-file: `-` for stdout

=== flags ===

  [-w]                       . watch mode
  [-build-info]              . print info about this build and exit
  [-version]                 . print the version of this build and exit
  [-help], -?                . print this help text and exit
```

# libraries/dependencies
- clangml : to convert to C to AST
- core.command : to parse command line arguments
- ocamlformat

# sample functionality
##### Example 1
```C
#include <stdio>

int main() {
  for (int i = 0; i < 5; i++) {
    printf("Hello World");
  }
}
```
to
```OCaml
let () =
  let rec main_aux (i : int) (stop : int -> bool) (inc : int -> int) : unit =
    match stop i with
    | true -> ()
    | false -> (printf "Hello world";
            main_aux (inc i) stop inc)
  in
  main_aux 0 (fun x -> x < 5) (fun x -> x + 1);
```

##### Example 2
```C
int main() {
  int a = 3;
  int b = 4;
  int c = a + b;
  int d = c + 2;
  return d;
}
```
to
```OCaml
let () =
  let a = 3 in
  let b = 4 in
  let c = a + b in
  let d = c + 2 in
  exit(d)  
```

##### Example Execution

if input file is called csample.c, and we want to output ocaml file called ocamloutput.ml, we call the command line as follows:
```
tocaml.exe csample.c ocamloutput.ml
```
There is an optional flag of `-w` so that ocamloutput.ml will continue to be regenerated after every change of csample.c


# todo
- [ ] c file to AST
  - [X] file to AST
  - [ ] stdin to AST ??
- [ ] translate AST to ocaml code
  - [ ] functions
  - [ ] statements
    - [ ] for-loop
    - [ ] if statements
    - [ ] switch statements
  - [ ] expressions
- [ ] print to file

# things to consider
- function declaration
- structs
- pointers
- memory arithmetic
- arrays
- macros
- enums
- unions
- typedefs
- casts
- function pointers?
- inline
- static
- extern
- preprocessor directives
