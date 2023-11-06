An overview of the purpose of the project
A list of libraries you plan on using
- Additionally if any of the libraries are either not listed above or are in the data processing category above, you will also be required to have successfully installed the library on all team member computers and have a small demo app working to verify the library really works. We require this because OCaml libraries can be flakey. You will need to submit this demo/ as part of the code submission for your design.
Commented module type declarations (.mli files) which will provide you with an initial specification to code to
- You can obviously change this later and don’t need every single detail filled out
- But, do include an initial pass at key types and functions needed and a brief comment if the meaning of a function is not clear.
Include a mock of a use of your application, along the lines of the Minesweeper example above but showing the complete protocol.
Also include a brief list of what order you will implement features.
If your project is an OCaml version of some other app in another language or a projust you did in another course etc please cite this other project. In general any code that inspired your code needs to be cited in your submissions.
You may also include any other information which will make it easier to understand your project.


Idea: Transpiler from c to ocaml

features:
	- best effort (implement as much of c lang as possible)
	- generates code with no mutation
	- -w (watch) mode to update whenever c file changes

dependencies:
	- clang to convert from c to AST
	- json parser
	- ocamlformat

things to consider:
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
