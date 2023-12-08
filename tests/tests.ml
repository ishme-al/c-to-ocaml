(*
  Put the tests for lib.ml functions here
*)

(* open Core;; *)
open OUnit2
open Lib

[@@@ocaml.warning "-32"]

let comments =
  "\n\
   // #include <stdio.h>\n\
   // #include <stdio.h>\n\
   int main()\n\
   {\n\
  \    int x = 1 + 2;\n\
  \    return 0;\n\
   }\n\n\
   //manual parse:\n\n\
   // look for basic keywords;\n\
   // de limit based on semi colons\n\
   // ask for input data types?\n\
   // ex: if user provides ocaml implementation for a file, we can map to it.\n\
   // if start with type declaration\n\
   // if start with variable name\n\
   // if start with functionName (delimit further based on ()\n\
   //manual parse:\n\n\
   // look for basic keywords;\n\
   // de limit based on semi colons\n\
   // ask for input data types?\n\
   // ex: if user provides ocaml implementation for a file, we can map to it.\n\
   // if start with type declaration\n\
   // if start with variable name\n\
   // if start with functionName (delimit further based on ()\n"

let comments_with_weird_spacing =
  "\n\
   // #include <stdio.h>\n\
   int\n\
   main()\n\
   {\n\
  \    int x = 1\n\
  \     +\n\
  \      2;\n\
  \      return        0;\n\
   }\n\n\
   //manual parse:\n\n\
   // look for basic keywords;\n\
   //             de limit based on semi colons\n\
   // ask for input data types?\n\
   //        ex: if user provides ocaml implementation for a file, we can map \
   to it.\n\
   // if start with type declaration\n\
   //                  if start with variable name\n\
   // if start with functionName (delimit further based on ()\n"

let foofunction1 =
  "\n\
   int foo(int a, int b) {\n\
  \  int x;\n\
  \  int y;\n\
  \  if (a < b) {\n\
  \    int z = 2;\n\
  \    x = b - a;\n\
  \    y = z + a;\n\
  \  } else {\n\
  \    int z = 3;\n\
  \    x = a - b;\n\
  \    y = z + b;\n\
  \  }\n\
  \  return x + y;\n\
   }\n\n\
   int main() {\n\
  \  int x = foo(foo(4, 6), 3);\n\
  \  return 0;\n\
   }\n"

let foofunction1_with_weird_spacing =
  "\n\
   int foo(int a, int b) {\n\
  \  int x;\n\
  \        int y;\n\
  \  if (a < b) {\n\
  \    int z = 2;\n\
  \            x = b - a;\n\
  \    y = z + a;\n\
  \  } \n\
   else {\n\
  \         int z = 3;\n\
  \    x = a - b;\n\
  \        y = z + b;\n\
  \  }\n\
  \  return x + y;\n\
   }\n\n\
   int main() {\n\
  \  int x = foo(foo(4, 6), 3);\n\
  \  return 0;\n\
   }\n"

let foofunction2 =
  "\n\
   int foo(int a, int b) {\n\
  \  int x = a;\n\
  \  int y = b;\n\
  \  return x + y;\n\
   }\n\n\
   int main() {\n\
  \  int x = foo(foo(4, 6), 3);\n\
  \  return 0;\n\
   }\n"

let functions =
  "\n\
   int test1(int a, int b) {\n\
  \    return a + b;\n\
   }\n\n\
   int test2(int a, char b) {\n\
  \    return a;\n\
   }\n\n\
   char test3(int a, char b) {\n\
  \    a = a * 2;\n\
  \    a = a + 3;\n\
  \    return b;\n\
   }\n"

let ifs =
  " \n\
  \  int main()\n\
   {\n\
  \    int x = 0;\n\
  \    int y= 0;\n\
  \    if(x > y) {\n\
  \        x = x + 1;\n\
  \    } else {\n\
  \        y = y + 1;\n\
  \    }\n\
  \     if(x == 0) {\n\
  \        x = y;\n\
  \     }\n\n\
  \     if(x == y) {\n\
  \        x = x + y  ;   \n\
  \    }\n\
  \    return 0;\n\
   }\n"

let intTest = "\nint main() {\n  int a;\n  a = 2;\n\treturn 0;\n}"
let main = "\nint main() {\n\treturn 0;\n}"

let statements =
  "\n\
   int main() {\n\
  \    int x = 2;\n\
  \    int y = 3;\n\
  \    int z = 4;\n\
  \    int a = x + y;\n\
  \    int b = z - y;\n\
  \    int c = z * y;\n\
  \    int d = z / y;\n\
  \    float e = 13;\n\n\
  \    return 0;\n\n\
   }\n"

let struct_test =
  "\nstruct myStruct {\n  int a;\n  int b;\n  float c;\n  char d;\n};\n"

let struct2 =
  "\n\
   struct myStructure {\n\
  \    int a;\n\
  \    int b;\n\
  \    char c;\n\
  \    float d;\n\
   };\n\
   int transformAB ( struct myStructure str) {\n\
  \    int c = str.a * str.b;\n\
  \    int b = str.a + str.b;\n\
  \    // int c = str.a * str.b;\n\
  \    return b + c;\n\
   };\n\n\
   int addAb ( struct myStructure str) {\n\
  \    return str.a + str.b;\n\
   };\n\n\
   int multAb ( struct myStructure str) {\n\
  \    return str.a * str.b;\n\
   };\n\n\
   int subAb ( struct myStructure str) {\n\
  \    return str.a - str.b;\n\
   };\n\n\
   int divideAb ( struct myStructure str) {\n\
  \    return str.a / str.b;\n\
   };\n"

(* do a string comparison of transpuled code and the expected transpiled code*)
(* please see the tests/transpiled folder to see the equivalent code formmated automatically**)
let test_transpiler _ =
  assert_equal "let () =\nlet x : int = 1  + 2 \n in\nexit(0 )\n"
    (parse comments);

  assert_equal
    "let foo (a : int) (b : int) : int = \n\
     let  (y,x)  = if a  < b \n\
    \ then let z : int = 2  in\n\
     let x  = b  - a \n\
    \ in\n\
     let y  = z  + a \n\
    \ in\n\
    \ (y,x) else let z : int = 3  in\n\
     let x  = a  - b \n\
    \ in\n\
     let y  = z  + b \n\
    \ in\n\
    \ (y,x)  in\n\
     x  + y \n\
     let () =\n\
     let x : int = (foo  (foo  4 6 )3 ) in\n\
     exit(0 )\n"
    (parse foofunction1);
  assert_equal
    "let foo (a : int) (b : int) : int = \n\
     let x : int = a  in\n\
     let y : int = b  in\n\
     x  + y \n\
     let () =\n\
     let x : int = (foo  (foo  4 6 )3 ) in\n\
     exit(0 )\n"
    (parse foofunction2);
  assert_equal
    "let test1 (a : int) (b : int) : int = \n\
     a  + b \n\
     let test2 (a : int) (b : char) : int = \n\
     a let test3 (a : int) (b : char) : char = \n\
     let a  = a  * 2 \n\
    \ in\n\
     let a  = a  + 3 \n\
    \ in\n\
     b "
    (parse functions);
  assert_equal
    "let () =\n\
     let x : int = 0  in\n\
     let y : int = 0  in\n\
     let  (y,x)  = if x  > y \n\
    \ then let x  = x  + 1 \n\
    \ in\n\
    \ (y,x) else let y  = y  + 1 \n\
    \ in\n\
    \ (y,x)  in\n\
     let  (x)  = if x  = 0 \n\
    \ then let x  = y  in\n\
    \ (x)  in\n\
     let  (x)  = if x  = y \n\
    \ then let x  = x  + y \n\
    \ in\n\
    \ (x)  in\n\
     exit(0 )\n"
    (parse ifs);

  assert_equal "let () =\nlet a  = 2  in\nexit(0 )\n" (parse intTest);
  assert_equal "let () =\nexit(0 )\n" (parse main);
  assert_equal
    "let () =\n\
     let x : int = 2  in\n\
     let y : int = 3  in\n\
     let z : int = 4  in\n\
     let a : int = x  + y \n\
    \ in\n\
     let b : int = z  - y \n\
    \ in\n\
     let c : int = z  * y \n\
    \ in\n\
     let d : int = z  / y \n\
    \ in\n\
     let e : float = 13  in\n\
     exit(0 )\n"
    (parse statements);
  assert_equal "type myStruct = { a: int; b: int; c: float; d: char; } "
    (parse struct_test);
  (* get a weird output error to stdout on this test, but the transpiled file is still correct*)
  assert_equal
    "type myStructure = { a: int; b: int; c: char; d: float; } let transformAB \
     (str : myStructure) : int = \n\
     let c : int = str.a  * str.b \n\
    \ in\n\
     let b : int = str.a  + str.b \n\
    \ in\n\
     b  + c \n\
     let addAb (str : myStructure) : int = \n\
     str.a  + str.b \n\
     let multAb (str : myStructure) : int = \n\
     str.a  * str.b \n\
     let subAb (str : myStructure) : int = \n\
     str.a  - str.b \n\
     let divideAb (str : myStructure) : int = \n\
     str.a  / str.b \n"
    (parse struct2)

let test_white_space_makes_no_change _ =
  assert_equal (parse comments_with_weird_spacing) (parse comments);
  assert_equal (parse foofunction1_with_weird_spacing) (parse foofunction1)

let transpiler_tests =
  "test_transpiler"
  >::: [
         "test_transpiler" >:: test_transpiler;
         "test_whitespace" >:: test_white_space_makes_no_change;
       ]

let series = "Transpiler tests for string" >::: [ transpiler_tests ]
let () = run_test_tt_main series
