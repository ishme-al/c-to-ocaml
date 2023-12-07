(*
  Put the tests for lib.ml functions here
*)

(* open Core;; *)
open OUnit2;;
open Lib;;
[@@@ocaml.warning "-32"]



let comments = "
// #include <stdio.h>
int main()
{
    int x = 1 + 2;
}

//manual parse:

// look for basic keywords;
// de limit based on semi colons
// ask for input data types?
// ex: if user provides ocaml implementation for a file, we can map to it.
// if start with type declaration
// if start with variable name
// if start with functionName (delimit further based on ()
"
let comments_with_weird_spacing = "
// #include <stdio.h>
int
main()
{
    int x = 1
     +
      2;
}

//manual parse:

// look for basic keywords;
//             de limit based on semi colons
// ask for input data types?
//        ex: if user provides ocaml implementation for a file, we can map to it.
// if start with type declaration
//                  if start with variable name
// if start with functionName (delimit further based on ()
"

let foofunction1 = "
int foo(int a, int b) {
  int x;
  int y;
  if (a < b) {
    int z = 2;
    x = b - a;
    y = z + a;
  } else {
    int z = 3;
    x = a - b;
    y = z + b;
  }
  return x + y;
}

int main() {
  int x = foo(foo(4, 6), 3);
  return 0;
}
"

let foofunction1_with_weird_spacing = "
int foo(int a, int b) {
  int x;
        int y;
  if (a < b) {
    int z = 2;
            x = b - a;
    y = z + a;
  } 
else {
         int z = 3;
    x = a - b;
        y = z + b;
  }
  return x + y;
}

int main() {
  int x = foo(foo(4, 6), 3);
  return 0;
}
"

let foofunction2 = "
int foo(int a, int b) {
  int x = a;
  int y = b;
  return x + y;
}

int main() {
  int x = foo(foo(4, 6), 3);
  return 0;
}
"

let functions = "
int test1(int a, int b) {
    return a + b;
}

int test2(int a, char b) {
    return a;
}

char test3(int a, char b) {
    a = a * 2;
    a = a + 3;
    return b;
}
"

let ifs = " 
  int main()
{
    int x = 0;
    int y= 0;
    if(x > y) {
        x = x + 1;
    } else {
        y = y + 1;
    }
     if(x == 0) {
        x = y;
     }

     if(x == y) {
        x = x + y  ;   
    }
    return 0;
}
" 



let intTest = "
int main() {
  int a;
  a = 2;
	return 0;
}"

let main = "
int main() {
	return 0;
}"

let statements = "
int main() {
    int x = 2;
    int y = 3;
    int z = 4;
    int a = x + y;
    int b = z - y;
    int c = z * y;
    int d = z / y;
    float a = 13;

    return 0;

}
"

let structTest = "
struct myStruct {
  int a;
  int b;
  float c;
  char d;
};
"


let struct2 = "
struct myStructure {
    int a;
    int b;
    char c;
    float d;
};
int transformAB ( struct myStructure str) {
    int c = str.a * str.b;
    int b = str.a + str.b;
    // int c = str.a * str.b;
    return b + c;
};

int addAb ( struct myStructure str) {
    return str.a + str.b;
};

int multAb ( struct myStructure str) {
    return str.a * str.b;
};

int subAb ( struct myStructure str) {
    return str.a - str.b;
};

int divideAb ( struct myStructure str) {
    return str.a / str.b;
};
"

(* do a string comparison of transpuled code and the expected transpiled code*)
(* please see the tests/transpiled folder to see the equivalent code formmated automatically**)
let test_transpiler _ =
  assert_equal ("let () =\nlet x : int = 1  + 2 \n in\n") (parse comments);

  assert_equal ("let foo (a : int) (b : int) : int = \nlet  (y,x)  = if a  < b \n then let z : int = 2  in\nlet x  = b  - a \n in\nlet y  = z  + a \n in\n (y,x) else let z : int = 3  in\nlet x  = a  - b \n in\nlet y  = z  + b \n in\n (y,x)  in\nx  + y \nlet () =\nlet x : int = (foo  (foo  4 6 )3 ) in\nexit(0 )\n") (parse foofunction1);
  assert_equal ("let foo (a : int) (b : int) : int = \nlet x : int = a  in\nlet y : int = b  in\nx  + y \nlet () =\nlet x : int = (foo  (foo  4 6 )3 ) in\nexit(0 )\n"  ) (parse foofunction2);
  assert_equal ("let test1 (a : int) (b : int) : int = \na  + b \nlet test2 (a : int) (b : char) : int = \na let test3 (a : int) (b : char) : char = \nlet a  = a  * 2 \n in\nlet a  = a  + 3 \n in\nb ") (parse functions);
  assert_equal ("let () =\nlet x : int = 0  in\nlet y : int = 0  in\nlet  (y,x)  = if x  > y \n then let x  = x  + 1 \n in\n (y,x) else let y  = y  + 1 \n in\n (y,x)  in\nlet  (x)  = if x  = 0 \n then let x  = y  in\n (x)  in\nlet  (x)  = if x  = y \n then let x  = x  + y \n in\n (x)  in\nexit(0 )\n") (parse ifs);

  assert_equal ("let () =\nlet a  = 2  in\nexit(0 )\n") (parse intTest);
  assert_equal ("let () =\nexit(0 )\n") (parse main);
  assert_equal ("let () =\nlet x : int = 2  in\nlet y : int = 3  in\nlet z : int = 4  in\nlet a : int = x  + y \n in\nlet b : int = z  - y \n in\nlet c : int = z  * y \n in\nlet d : int = z  / y \n in\nexit(0 )\n") (parse statements);
  assert_equal ("type myStruct = { a: int; b: int; c: float; d: char; } ") (parse structTest);
  (* get a weird output error on this test, but the translation is still correct*)
  assert_equal ("type myStructure = { a: int; b: int; c: char; d: float; } let transformAB (str : myStructure) : int = \nlet c : int = str.a  * str.b \n in\nlet b : int = str.a  + str.b \n in\nb  + c \nlet addAb (str : myStructure) : int = \nstr.a  + str.b \nlet multAb (str : myStructure) : int = \nstr.a  * str.b \nlet subAb (str : myStructure) : int = \nstr.a  - str.b \nlet divideAb (str : myStructure) : int = \nstr.a  / str.b \n") (parse struct2)


  let test_white_space_makes_no_change _ =
    assert_equal (parse comments_with_weird_spacing) (parse comments);
    assert_equal (parse foofunction1_with_weird_spacing) (parse foofunction1)

  

let transpiler_tests =
  "test_transpiler"
  >::: [
          "test_transpiler" >:: test_transpiler ;
        ]
  
let series =
"Assignment4 Tests"
>::: [
       transpiler_tests;
      ]
let () = run_test_tt_main series
        