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
