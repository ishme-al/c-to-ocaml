Assignment 4: N-Grams and a real app
------------------------------------

### Part I

For Part I of this assignment you will be writing various modules and functions which will lead to a n-gram model generator.  See `src/lib.ml` in the tempate for the specific requirements.

You will also need to write tests with good coverage for your Part I submission.

### Part II

For Part II you will make a standalone app which uses the functions from part I.  If you need more library functions for your app, you can put them in `lib.ml`.

You will need to continue to keep good unit test coverage on your library code.  Note you do not need to make any acceptance tests for the executable itself, but you should test any auxiliary library functions which are amenable to unit testing.

In addition, write  at least one `Base_quickcheck` random test for one of your OUnit tests following the [Quickcheck lecture](https://pl.cs.jhu.edu/fpse/lecture/specification-test.html#quickcheck).  Since the input data is random, you may not necessarily know the correct answer but it suffices to perform sanity checks.  For example, `ngrams.ml` indicates a need to sanititize the input strings and you could check to make sure your function indeed removes the things it should (and not the things it should not).

As usual we will give two due dates for the two parts.

### The file structure

* [Use the this zip file](https://pl.cs.jhu.edu/fpse/assignments/assignment4.zip) as the initial template for your assignment. 
* Like assignment 1-3, we are giving you a skeleton to fill in.  Your Part I code will go in the file  `src/lib.ml` and Part II will be in  `src/ngrams.ml` (plus, add any new auxiliary functions needed to Part I's `lib.ml` for unit testing).  You will also need to make a unit tester in `tests/tests.ml` following the previous assignments.

### Submission and Grading
* As usual, run a final `dune clean; dune build` and then upload `_build/default/assignment4.zip` to Gradescope.