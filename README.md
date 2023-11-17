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

# libraries
clangml  
parse cmdline arguments?  
ocamlformat  

# sample functionality
covert
```C
#include <stdio>

int main() {
  for (int i = 0; i < 5; i++) {
    printf("Hello World");
  }
  return 0;
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
  main_aux 0 (fun x -> x < 5) (fun x -> x + 1)
```


# todo
mli declarations


# dependencies
- clang to convert from c to AST

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
