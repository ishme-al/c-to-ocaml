(*

FPSE Assignment 4

Name                  : 
List of Collaborators :

*)
open Core

(*
  --------------
  BROAD OVERVIEW
  --------------

  In this assignment you will implement a simple n-gram model.

  Part I consists of some library routines, and Part II will be a command-line tool to build and use an n-gram model which makes use of your library.

  Using the n-gram model of sequences and probabilities, we'll take in some sequence of items, and then use it as a basis to generate more similar sequences (for example, sentences of words, lists of numbers, etc.), or evaluate the likelihood of seeing particular sequences.

  The comments in this file will describe the expectations for Part I. Before you code here, we suggest you also read the comments in the Part II file to better understand the end goal and cater your code to that goal. We understand that it's a lot to read, but it's better to read it here than to have to scrape student questions on Courselore.


  ----------
  BACKGROUND
  ----------

  The general intuition is simple: if we want to predict what comes next in a sequence of items, we can probably do so on the basis of the elements which preceded it. Moreover, we can 
  probably ignore parts of the sequence which came _far_ before the element we want to predict and focus our attention on the immediately previous couple of items.

  Consider sentences of words in English text, a very common type of sequence to apply this approach to. If we are given that the word we want to predict came after:

  "take this boat for a spin out on the" ???

  Then we could say that "water" is more likely than "town" to follow. If we have less context, say only 2 words:

  "on the" ???

  We will naturally make a poorer approximation of the true distribution, but it may be sufficient for some purposes anyway and will be easier to estimate. How can we estimate the actual distribution of words efficiently, then?

  We will need to take in some observed sequence of words or tokens, called a _corpus_.  Let's say we want to keep two words of context when predicting what comes next, based on the provided corpus. Then we can 
  just keep track of every 3-tuple of consecutive words in the input, and count how often they appear.

  For example, say we observe the triples (i.e. 3-grams)

  ("take", "this", "boat"), ("this", "boat", "for"), ... ("on", "the", "water").

  Then, if we index these properly, we can predict what should follow ("on", "the") by just sampling randomly from among all the tuples which started with that prefix, and using the last element of the tuple as our prediction.  Naturally, words which appear more frequently in the context specified should then be given more weight, and words which do not appear in our corpus after the given sequence will not be chosen at all, so our prediction should be a reasonable estimate for the empirical distribution.

  If we instead count 5-tuples rather than 3-tuples, we can make better predictions with the greater context, which will then more closely match the true sequence properties. However, we will also be able to observe fewer unique 5-tuples overall than 3-tuples, which will mean we need greater amounts of data to properly use a larger n-gram size.


  Feel free to read these useful resources to better understand n-grams:
  - https://blog.xrds.acm.org/2017/10/introduction-n-grams-need/
  - https://web.stanford.edu/~jurafsky/slp3/slides/LM_4.pdf
  - https://medium.com/mti-technology/n-gram-language-model-b7c2fc322799

  In this document we follow the standard terminology (which can be confusing) and refer to "n-grams" when it seems like we might mean "(n-1)-grams" since there are n-1 items of prefix in an n-gram.  For example, a 3-gram has two items of prefix and the prefix plus the one-item of prediction gives a 3-gram.

  ------------
  EXPECTATIONS
  ------------

  The library code in Part I will support the main functionality for Part II. Your submission for Part I might change during your Part II submission to better accommodate the final functionality. This assignment is split into two parts to help you get started early.

  There are no autograder tests for this part. Gradescope will run your own tests in `tests/tests.ml` to ensure they pass, and the course staff will thoroughly inspect your code for good code style and a strong foundation heading into Part II. It will also be inspected to make sure you meet all requirements specified in this doc.

  There are are few implementation expectations:
  * Your code is functional with no mutation.
  * You use functors adequately.
  * You choose efficient data structures.
  * You write plenty of helper functions to keep your code short and readable.
  * Your code is well-tested with high code coverage.
  * You have a `lib.mli` file to provide signatures and expose public members for testing.
  * You meet the functionality requirements specified below.


  --------------------------
  FUNCTIONALITY REQUIREMENTS
  --------------------------

  You will design a functor to create a "distribution" module. The argument of the functor will be a module which specifies the type of items in the sequence/distribution (refer to "Broad Overview" section above). These might be strings or ints, or anything that is comparable (but the standard usage in natural language is strings). An appropriate signature would be `Item : Core.Map.Key` as the functor argument.

  The functor will return a module that has a type to represent the distribution. The "distribution" is a mapping from an n-gram to a multiset of items that follow that n-gram in the given sequence. For example:
    Suppose `Item` = `Int` is the functor argument, and the input sequence of integers is
      [1; 2; 3; 4; 4; 4; 2; 2; 3; 1]
    where the model uses bigrams (2-grams) to get one item of context. Then the distribution is
      { 
        [1] -> {2}; 
        [2] -> {3; 2; 3};
        [3] -> {4; 1};
        [4] -> {4; 4; 2};
         |        |
         |        \------------------------ ...was followed by each of these elements
         \-- this sequence (of length 1 in this example)  ...
      }
    If there are instead two items of context because the model used 3-grams, then the distribution is
      {
        [1; 2] -> {3};
        [2; 3] -> {4; 1};
        [3; 4] -> {4};
        [4; 4] -> {4; 2};
        [4; 2] -> {2};
        [2; 2] -> {3};
          |        |
          |        \------- ...was followed by each of these elements
          \-- this sequence...
      }

  We think it's a great implementation choice to use `Core.Map` to map the n-grams to their multiset of right contexts. This will be a good exercise in using module signatures and functors.

  The module will be able to make a distribution from a given input sequence (i.e. list). For example
    ```
    module Distribution (Item : Map.Key) = struct
      ...
      val make_distribution : Item.t list -> n:int -> t
      ...
    end
    ```
  You don't have to follow these names or signatures, but you do have to make a functor. Points will be deducted from your submission if you do not use a functor.

  Further, using this distribution, you will have a function called `sample_random_sequence` that takes an input n-gram and creates a k-length sequence that is randomly sampled from the distribution using the n-gram as starting context. The sequence might terminate before length k, if necessary.

  We will walk you through one example of this with the above distribution and two items of context.
    Say the input n-gram is [1; 2], and we want a 5-length sequence.
    Then the only possible following item is 3 (because [1; 2] -> {3} above), and the running sequence is
      [1; 2; 3].
    Now the context is
      [2; 3].
    Look at the above distribution to see what can follow this context (here, [2; 3] -> {4; 1}). So we sample from
      {4; 1}
    at random. Say this comes out as 4. So the running sequence is now
      [1; 2; 3; 4]
    and the new context is
      [3; 4].
    So we sample from
      {4}
    which makes the running sequence
      [1; 2; 3; 4; 4]
    which has length k = 5, and we're done because we hit the desired length.

    If from {4; 1} we pulled the item 1, then the sequence would have become [1; 2; 3; 1], and the new context is [3; 1], which never appears in the original sequence, and hence there's no appropriate next item, so we stop at length 4, which is short of k = 5. That's okay, and it's a valid output.

  In summary, the two functionality requirements for Part I are:
  * A functor that has a type to represent a distribution, where the underlying type of the distribution is provided as the functor argument.
  * A way to create a distribution from an input list.
  * A function called `sample_random_sequence` to randomly sample from the distribution until it hits the desired length, or until there is nothing to sample. We'd like it to be called example `sample_random_sequence` so we can find it easily when grading.
  * You have created tests to thoroughly test your code according to the specifications in this document, and all of your tests pass.




  ----
  TIPS
  ----

  If you have a module `Item : Map.Key`, see how you can make a module `Item_list : Map.Key` where `Item_list.t = Item.t list`. This way you can map the n-grams to their context using a map (which is an appropriately efficient data structure).

  A list or a `Core.Bag` (i.e. multiset) might be an appropriate way to store the right contexts. A `Core.Set` won't work because that doesn't consider the weight of the item; more common right contexts are more likely to be sampled (note the one-item-of-context example above).

  Because this library uses randomness, you might like to pass in a module as a functor argument that provides the random numbers. During testing, you pass it a module that gives predictable numbers, but during regular usage in Part II, you pass it the real `Random` module.

    Your code will likely use the `Random` module only by calling a function `Random.int : int -> int`, so for testing you can provide any module that satisfies the signature `sig val int : int -> int end`.

  If the requirement is not stated exactly in this description, then you have room to implement it how you like, or you may meet different requirements. You only need to pass your own tests and appropriately prepare for Part II.

  If you create any other files for this assignment, then please edit the top-level `dune` file to add them to the deps and zip and submit them.

*)

(* open Core *)



module Distribution (Item : Map.Key) = 
struct

  (*
    module to build a list of item as a map key   
  *)
  module Item_list : Map.Key with type t = Item.t list =
  struct
    type t = Item.t list [@@deriving compare, sexp]
    let compare = List.compare Item.compare
    let t_of_sexp = List.t_of_sexp Item.t_of_sexp
    let sexp_of_t = List.sexp_of_t Item.sexp_of_t 
  end

  (*
    type to represent a map with a key of list of items
  *)
  module Ngram_map = Map.Make(Item_list) 

  (*
    map from all the first parts of ngrams to list of possible ending words.
  *)
  type distribution = Item_list.t Ngram_map.t

  (*
    make distribution function to take a list of itmes and build a map of start of ngrams to possible endings.
  *)
  let make_distribution (items: Item.t list)  (n: int): distribution =
    (* returns a list of first n components of a list (the n gram starting at beginning of list)*)
    if n <=0 then
      failwith "Exception because n is not a valid ngram length"
    else
      let rec get_first_n (n: int) (items: Item.t list): Item.t list  =
        if n = 0 then []
        else match items with 
          | hd:: tail -> hd :: (get_first_n (n-1) tail) 
          | _ -> []
      in

      (* returns a list of all ngrams in the item list*)
      let rec get_n_gram_list (items: Item.t list): Item.t list list =
        if List.length items >= n then
          let ngram = get_first_n n items in
          let remaining = match List.tl items with 
            | Some a -> a
            | None -> failwith "error" in
          ngram :: get_n_gram_list remaining

        else []
      in

      (* adds the ngram to the distribution and returns the new map*)
      let construct_distribution (my_distribution: distribution ) (ngram: Item.t list): distribution =
        let first_part, last_word_list = List.split_n ngram (n-1) in
        let last_word = match List.nth last_word_list 0 with 
          | Some d -> d 
          | None -> failwith "error" in

        (* appends word from this ngram onto the end of the existing choices for this ngram context*)
        let current_predictions = match Map.find my_distribution first_part with 
          | Some current_words -> (current_words @ [last_word])
          | None -> [last_word] in
        (* removes current value and replaces with new one*)
        let my_map = Map.remove my_distribution first_part in
        Map.add_exn my_map ~key:first_part ~data:current_predictions
      in

      (* list of all ngrams*)
      let n_gram_list = get_n_gram_list items in
      (* creates an empty ngram map and adds all ngrams*)
      let empty_dist = Ngram_map.empty in
      List.fold_left n_gram_list ~init:empty_dist  ~f:construct_distribution



  (* generates a random sample with context of k*)
  let sample_random_sequence (my_distribution: distribution) (ngram: Item.t list) (k: int) (number_generator: (int -> int)) =
    (* function to sample a word with a context of first_part, and repeats this length times(while updating context)*)

    let rec get_next_word (word_list: Item.t list) (first_part: Item.t list) (length: int): Item.t list =
      (* if length is reached on ngram context has not been seen before*)
      if length < 0 then
        failwith "Exception because negative ngram length was inputted"
      else 
        if length = 0 || not(Map.mem my_distribution first_part) then
          word_list
        else 
          (* get list of all words resulting from this context from the map*)
          let next_word_choices = match Map.find my_distribution first_part with 
            | Some a -> a
            | None -> failwith "error" in
          (* randomly pick one word from list of words*)
          (* let next_word = match List.nth next_word_choices (Random.int (List.length next_word_choices)) with  *)
          let next_word = match List.nth next_word_choices (number_generator (List.length next_word_choices)) with 
            | Some a -> a 
            | None -> failwith "error" in
          (* remove the first word from the current ngram, and replace with new word to create new ngram context*)
          let remove_first_word = match List.tl first_part with 
            | Some a -> a 
            | None -> failwith "error" in
          let new_first_part = remove_first_word @ [next_word] in
          (* repeat to generate another word*)
          get_next_word (word_list @ [next_word]) new_first_part (length - 1)
      in
      (* return list of all words*)
      get_next_word [] ngram k

  (* helper function for testing purposes to directly check if distribution map is correct*)
  let get_distribution_as_map (my_distribution:distribution): Item_list.t Ngram_map.t =
    my_distribution

end

