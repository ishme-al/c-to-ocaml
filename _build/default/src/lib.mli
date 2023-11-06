(* Intentionally left empty until your implementation *)

(* module Make (_ : Params) : S *)

module Distribution (Item: Core.Map.Key) :
sig

  module Item_list : Core.Map.Key

  module Ngram_map : Core.Map.S

  type distribution = Item_list.t Ngram_map.t

  val make_distribution : Item.t list -> int -> distribution
  val sample_random_sequence : distribution -> Item.t list -> int -> (int -> int) -> Item.t list

  val get_distribution_as_map: distribution -> Item_list.t Ngram_map.t
end
