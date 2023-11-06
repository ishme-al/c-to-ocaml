(*
  Put the tests for lib.ml functions here
*)

open Core;;
open OUnit2;;

module DInt = Lib.Distribution(Int)
module DString = Lib.Distribution(String)


let distribution_3 = DInt.make_distribution [1;2;3;4;5;6;7;8;9;10] 3 
let distribution_4 = DInt.make_distribution [1;2;3;4;5;6;7;8;9;10] 4
let distribution_5 = DInt.make_distribution [1;2;3;4;5;6;7;8;9;10] 5 
let distribution_7 = DInt.make_distribution [1;2;3;4;5;6;7;8;9;10] 7 
let distribution_repeats = DInt.make_distribution [1;2;4;1;2;5;1;2;6;1; 2; 8; 1; 2 ;9] 3
let distribution_repeats_2 = DInt.make_distribution [1;2;4;1;2;5;1;2;6;1; 2; 8; 1; 2 ;9; 1; 2; 4; 9; 1] 3
let distribution_random = DInt.make_distribution [1;2;3;2;3;4;2;3] 3 

let distribution_3_string = DString.make_distribution ["1";"2";"3";"4";"5";"6";"7";"8";"9";"10"] 3 
let distribution_4_string = DString.make_distribution ["1";"2";"3";"4";"5";"6";"7";"8";"9";"10"] 4
let distribution_5_string = DString.make_distribution ["1";"2";"3";"4";"5";"6";"7";"8";"9";"10"] 5 
let distribution_7_string = DString.make_distribution ["1";"2";"3";"4";"5";"6";"7";"8";"9";"10"] 7 
let distribution_repeats_string = DString.make_distribution ["1";"2";"4";"1";"2";"5";"1";"2";"6";"1";"2"; "8"; "1"; "2" ;"9"] 3
let distribution_repeats_2_string = DString.make_distribution ["1";"2";"4";"1";"2";"5";"1";"2";"6";"1"; "2"; "8"; "1"; "2" ;"9"; "1"; "2"; "4"; "9"; "1"] 3
let distribution_random_string = DString.make_distribution ["1";"2";"3";"2";"3";"4";"2";"3"] 3 

let unmasked_distribution_3 = distribution_3 |> DInt.get_distribution_as_map
let unmasked_distribution_4 = distribution_4 |> DInt.get_distribution_as_map
let unmasked_distribution_5 = distribution_5 |> DInt.get_distribution_as_map
let unmasked_distribution_7 = distribution_7 |> DInt.get_distribution_as_map
let unmasked_distribution_random = distribution_random |> DInt.get_distribution_as_map
let unmasked_distribution_repeats = distribution_repeats |> DInt.get_distribution_as_map

let unmasked_distribution_3_string = distribution_3_string |> DString.get_distribution_as_map
let unmasked_distribution_4_string = distribution_4_string |> DString.get_distribution_as_map
let unmasked_distribution_5_string = distribution_5_string |> DString.get_distribution_as_map
let unmasked_distribution_7_string = distribution_7_string |> DString.get_distribution_as_map
let unmasked_distribution_random_string = distribution_random_string |> DString.get_distribution_as_map
let unmasked_distribution_repeats_string = distribution_repeats_string |> DString.get_distribution_as_map


let remove_option (options: 'a option): 'a =
  match options with
  | Some a -> a 
  | None -> failwith "Should never occur"

let build_item_list (input: string): DInt.Item_list.t =
  DInt.Item_list.t_of_sexp (Sexp.of_string input)

let build_ngram_key (input: string): DInt.Ngram_map.Key.t =
  DInt.Ngram_map.Key.t_of_sexp (Sexp.of_string input)

  let build_item_list_string (input: string): DString.Item_list.t =
    DString.Item_list.t_of_sexp (Sexp.of_string input)
  
  let build_ngram_key_string (input: string): DString.Ngram_map.Key.t =
    DString.Ngram_map.Key.t_of_sexp (Sexp.of_string input)

let random_generate_zero (input: int) : int =
  input - input

let random_generate_one (input: int) : int =
  if (input mod 2) = 1  then
    0
  else 
    1


let test_make_distribution_int _ =
  assert_equal (build_item_list "(3)") (remove_option (Core.Map.find unmasked_distribution_3  (build_ngram_key "(1 2)") ));
  assert_equal (build_item_list "(4)") (remove_option (Core.Map.find unmasked_distribution_3  (build_ngram_key "(2 3)") ));
  assert_equal (build_item_list "(5)") (remove_option (Core.Map.find unmasked_distribution_3  (build_ngram_key "(3 4)") ));
  assert_equal (build_item_list "(6)") (remove_option (Core.Map.find unmasked_distribution_3  (build_ngram_key "(4 5)") ));
  assert_equal (build_item_list "(7)") (remove_option (Core.Map.find unmasked_distribution_3  (build_ngram_key "(5 6)") ));
  assert_equal (build_item_list "(8)") (remove_option (Core.Map.find unmasked_distribution_3  (build_ngram_key "(6 7)") ));
  assert_equal (build_item_list "(4)") (remove_option (Core.Map.find unmasked_distribution_4  (build_ngram_key "(1 2 3)") ));
  assert_equal (build_item_list "(6)") (remove_option (Core.Map.find unmasked_distribution_5  (build_ngram_key "(2 3 4 5)") ));
  assert_equal (build_item_list "(7)") (remove_option (Core.Map.find unmasked_distribution_7  (build_ngram_key "(1 2 3 4 5 6)") ));
  assert_equal (build_item_list "(3)") (remove_option (Core.Map.find unmasked_distribution_random  (build_ngram_key "(1 2)") ));
  assert_equal (build_item_list "(4 5 6 8 9)") (remove_option (Core.Map.find unmasked_distribution_repeats  (build_ngram_key "(1 2)") ));
  assert_equal (build_item_list "(2 4)") (remove_option (Core.Map.find unmasked_distribution_random  (build_ngram_key "(2 3)") ));
  assert_equal (build_item_list "(2)") (remove_option (Core.Map.find unmasked_distribution_random  (build_ngram_key "(3 4)") ))

let test_sample_generation_int _ =
  assert_equal ([3; 4]) (DInt.sample_random_sequence distribution_3 [1;2] 2 random_generate_zero);
  assert_equal ([3; 4; 5]) (DInt.sample_random_sequence distribution_3 [1;2] 3 random_generate_zero);
  assert_equal ([3; 4; 5; 6]) (DInt.sample_random_sequence distribution_3 [1;2] 4 random_generate_zero);
  assert_equal ([]) (DInt.sample_random_sequence distribution_3 [9;10] 2 random_generate_zero);
  assert_equal ([]) (DInt.sample_random_sequence distribution_random [1;5] 8 random_generate_zero);
  assert_equal ([]) (DInt.sample_random_sequence distribution_random [1;5] 8 random_generate_one);
  assert_equal ([3;4;2;3; 4; 2; 3; 4]) (DInt.sample_random_sequence distribution_random [1;2] 8 random_generate_one);
  assert_equal ([4; 1; 2; 4; 1; 2; 4; 1]) (DInt.sample_random_sequence distribution_repeats [1;2] 8 random_generate_one);
  assert_equal ([1; 2; 4; 1; 2; 4; 1; 2]) (DInt.sample_random_sequence distribution_repeats [2;4] 8 random_generate_one);
  assert_equal ([9; 1; 2; 5; 1; 2; 5; 1]) (DInt.sample_random_sequence distribution_repeats_2 [2;4] 8 random_generate_one)

let test_make_distribution_string _ =
    assert_equal (build_item_list_string "(3)") (remove_option (Core.Map.find unmasked_distribution_3_string  (build_ngram_key_string "(1 2)") ));
    assert_equal (build_item_list_string"(4)") (remove_option (Core.Map.find unmasked_distribution_3_string  (build_ngram_key_string "(2 3)") ));
    assert_equal (build_item_list_string "(5)") (remove_option (Core.Map.find unmasked_distribution_3_string  (build_ngram_key_string "(3 4)") ));
    assert_equal (build_item_list_string "(6)") (remove_option (Core.Map.find unmasked_distribution_3_string  (build_ngram_key_string "(4 5)") ));
    assert_equal (build_item_list_string "(7)") (remove_option (Core.Map.find unmasked_distribution_3_string  (build_ngram_key_string "(5 6)") ));
    assert_equal (build_item_list_string "(8)") (remove_option (Core.Map.find unmasked_distribution_3_string  (build_ngram_key_string "(6 7)") ));
    assert_equal (build_item_list_string "(4)") (remove_option (Core.Map.find unmasked_distribution_4_string  (build_ngram_key_string "(1 2 3)") ));
    assert_equal (build_item_list_string "(6)") (remove_option (Core.Map.find unmasked_distribution_5_string  (build_ngram_key_string "(2 3 4 5)") ));
    assert_equal (build_item_list_string "(7)") (remove_option (Core.Map.find unmasked_distribution_7_string  (build_ngram_key_string "(1 2 3 4 5 6)") ));
    assert_equal (build_item_list_string "(3)") (remove_option (Core.Map.find unmasked_distribution_random_string  (build_ngram_key_string "(1 2)") ));
    assert_equal (build_item_list_string "(4 5 6 8 9)") (remove_option (Core.Map.find unmasked_distribution_repeats_string  (build_ngram_key_string "(1 2)") ));
    assert_equal (build_item_list_string "(2 4)") (remove_option (Core.Map.find unmasked_distribution_random_string  (build_ngram_key_string "(2 3)") ));
    assert_equal (build_item_list_string "(2)") (remove_option (Core.Map.find unmasked_distribution_random_string  (build_ngram_key_string "(3 4)") ))
  
  let test_sample_generation_string _ =
    assert_equal (["3"; "4"]) (DString.sample_random_sequence distribution_3_string ["1";"2"] 2 random_generate_zero);
    assert_equal (["3"; "4"; "5"]) (DString.sample_random_sequence distribution_3_string ["1";"2"] 3 random_generate_zero);
    assert_equal (["3"; "4"; "5"; "6"]) (DString.sample_random_sequence distribution_3_string ["1";"2"] 4 random_generate_zero);
    assert_equal ([]) (DString.sample_random_sequence distribution_3_string ["9";"10"] 2 random_generate_zero);
    assert_equal ([]) (DString.sample_random_sequence distribution_random_string ["1";"5"] 8 random_generate_zero);
    assert_equal ([]) (DString.sample_random_sequence distribution_random_string ["1";"5"] 8 random_generate_one);
    assert_equal (["3";"4";"2";"3"; "4"; "2"; "3"; "4"]) (DString.sample_random_sequence distribution_random_string ["1";"2"] 8 random_generate_one);
    assert_equal (["4"; "1"; "2"; "4"; "1"; "2"; "4"; "1"]) (DString.sample_random_sequence distribution_repeats_string ["1";"2"] 8 random_generate_one);
    assert_equal (["1"; "2"; "4"; "1"; "2"; "4"; "1"; "2"]) (DString.sample_random_sequence distribution_repeats_string ["2";"4"] 8 random_generate_one);
    assert_equal (["9"; "1"; "2"; "5"; "1"; "2"; "5"; "1"]) (DString.sample_random_sequence distribution_repeats_2_string ["2";"4"] 8 random_generate_one)

let ngram_tests =
  "ngram tests"
  >::: [
          "make_distribution" >:: test_make_distribution_int ;
          "sample_generation" >:: test_sample_generation_int ;
          "make_distribution_int" >:: test_make_distribution_string ;
          "sample_generation_string" >:: test_sample_generation_string ;
        ]
  
let series =
"Assignment4 Tests"
>::: [
        ngram_tests;
      ]
let () = run_test_tt_main series
        