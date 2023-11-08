# tocaml
Transpiler from c to ocaml

# libraries
clangml  
parse cmdline arguments?  
ocamlformat  

# todo
mli declarations

# usage
./tocaml [-w] [input-file] [output-file]  

    w: watch mode
    input-file: can be `-` for stdin
    output-file: can be `-` for stdin

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
