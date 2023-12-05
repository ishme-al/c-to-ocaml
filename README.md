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
- clangml: to convert to C to AST
- core.command: to parse command line arguments
- ocamlformat-lib: format output code

# Design choices
- Elegance over correctness
- All ints are converted to pure ocaml `int`

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


##### Current Demo Functionality
Please look at lib.mli to see sample logic to parse through and translate c code.
Note that only the parse function needs to be exposed in order translate the c code, the other functions are there just to demonstrate the translation workflow.
Note, the visualize_ast and custom_print functions are in the ml and not mli file because those are purely to beign visualize the ast(to help while developing) and do not play a part in translation.

To show that the clangml library works to parse through c files, we have 3 main outputs. In the argument output file, we print the name of the 
first function given, and the function body. This is taken care of the "visualize_ast" function in lib.ml. Prinitng out the contents of the actualy function body is unimplemented still.
Then, we print out "let functionname = " to the output file as well.
Finally, to standard output, we use the ast to print out all statements within the file.
For example, if we call 
tocaml.exe test1.c testout1
with test1.c looking like:
```C
int main() {
  int a;
  a = 2;
	return 0;
}
```
the testout1 file looks like:
```txt
Function_decl:main 
Function_body:
let main = 
```

with standard output looking like:
```txt
int x = 1 + 2;
while (x < 3) {x --;}return 0;%   
```

Similarly, 
with test1.c looking like:
```C
// #include <stdio.h>
int notmain()
{
    int x = 1 + 2;

    for(int a =0; a<10; a++) {
        x = x + 1;
    }
    while( x< 3) {
        x--;
    }
    return 0;
}
```
the testout1 file looks like:
```txt
Function_decl:notmain 
Function_body:
let notmain = 
```
```txt
with standard output like :
int x = 1 + 2;
for (int a = 0; a < 10; a ++) {x = x + 1;}while (x < 3) {x --;}return 0;%    
```

Feel free to look at the test1.c, test2.c, testout1, and testout2 to verify this.

# todo
- [x] c file to AST
  - [x] file to AST
  - [x] stdin to AST ??
- [ ] translate AST to ocaml code
  - [ ] functions
  - [ ] statements
    - [ ] for-loop
    - [ ] if statements
    - [ ] switch statements
  - [ ] expressions
- [x] print to file

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
