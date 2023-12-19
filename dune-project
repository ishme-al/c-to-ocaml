(lang dune 3.12)
 (generate_opam_files true)
 (authors "Aprina" "Ishmeal" "Nish")
 (maintainers "nparuch1@gmail.com")
 (package
  (name tocaml)
  (synopsis "Transpile c to ocaml code")

  (allow_empty)
  
  (description "A longer description")
  (depends
   (ounit2 (>= 2.2.7))
   (core (>= 0.16.2))
   (clangml (>= 4.8.0))
   (ocamlformat-lib (>= 0.26.1))
   (core_unix (>= 0.16.0))
))
