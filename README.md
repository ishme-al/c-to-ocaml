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
also btw fswatch is very broken. Expect it to fail on your distribution.

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


# project submission notes
## tests
When `dune test` is run we compile all source files in `source` folder and transpile them to `actual`. Then each file is ran, comparing their output and return code with expected values in the code and in `expected` folder. You can see the transpiled files in the `actual` folder.


# todo
- [x] c file to AST
  - [x] file to AST
  - [x] stdin to AST ??
- [ ] translate AST to ocaml code
  - [x] functions
    - [x] parsing parameters
  - [x] statements
    - [x] for-loop
    - [x] if statements
    - [ ] switch statements
  - [x] expressions
    - [x] literals
    - [x] binary operators
      - [x] for non-int types
    - [ ] others :)
- [x] format output string
- [x] print to file
- [x] watch feature (partially done)

# things to implement
- [x] function declaration
- [x] conditional statements
- [x] loops
- [x] structs
- [x] arrays
- [ ] enums
- [x] i/o (to stdin stdout only?) - partially done for print f

##### Example Execution
if input file is called csample.c, and we want to output ocaml file called ocamloutput.ml, we call the command line as follows:
```
tocaml.exe csample.c ocamloutput.ml
```
There is an optional flag of `-w` so that ocamloutput.ml will continue to be regenerated after every change of csample.c

###### Ast visualization
go to viewast.ml and copy and paste all funcitons into utop.
Running viewAst "filename" will provide ast of entire file, while other functions will help pick out asts of specific functions, structs, or lines within those functions
