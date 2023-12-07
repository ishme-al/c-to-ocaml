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

# issues
* if the file does not end in `.c` it fails
* tests
* fix fswatch

# libraries/dependencies
- core: is good
- clangml: convert C to AST
- fswatch: watch filesystem
- ocamlformat-lib: format output code

## ocamlformat-lib issues
since this [fix](https://github.com/ocaml-ppx/ocamlformat/pull/2481) is not merged into opam (waiting for a release after 0.26.1), you will need to run
```bash
opam pin ocamlformat https://github.com/ocaml-ppx/ocamlformat.git
opam pin ocamlformat-lib https://github.com/ocaml-ppx/ocamlformat.git
opam pin ocamlformat-rpc-lib https://github.com/ocaml-ppx/ocamlformat.git
```

## fswatch issues
We just [fixed a bug](https://github.com/kandu/ocaml-fswatch/pull/6) with fswatch.
For now (until it gets [merged](https://github.com/ocaml/opam-repository/pull/24902) into opam), run
```bash
opam pin https://github.com/kandu/ocaml-fswatch.git
```

### alpine, arch, debian, opensuse, oracle, ubuntu (and probably more) users
there is a packaging [issue](https://github.com/ocaml/opam-repository/issues/22256) for `libfswatch`. Here is a fix that works (for debian/ubuntu derived? not sure about rest) (source: from the same issue)
```bash
sudo apt install fswatch
echo "/usr/lib/x86_64-linux-gnu/libfswatch" > /etc/ld.so.conf.d/fswatch.conf && ldconfig
LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/libfswatch opam pin https://github.com/kandu/ocaml-fswatch.git --no-depexts
# ^ combined with the fswatch fix above
```
then, prepend `LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/libfswatch` to `dune build` and such

### windows users
fswatch requires cygwin. Have not tested this install process.

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
  main_aux 0 (fun x -> x >= 5) (fun x -> x + 1);
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
  - [x] functions
    - [x] parsing parameters
  - [ ] statements
    - [ ] for-loop
    - [x] if statements
    - [ ] switch statements
  - [ ] expressions
- [x] format output string
- [x] print to file
- [ ] watch feature

# things to implement
- [x] function declaration
- [x] structs
- [ ] operations for non-int types
- [ ] arrays
- [ ] enums
- [ ] i/o (to stdin stdout only?)

# things to consider
- pointers
- memory arithmetic
- macros
- unions
- typedefs
- casts
- function pointers?
- inline
- static
- extern
- preprocessor directives
