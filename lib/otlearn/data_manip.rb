# frozen_string_literal: true

# Author: Bruce Tesar
#
# This file contains a collection of methods for generating and
# manipulating data.

require 'set'

module OTLearn
  # Given a list of winner_loser pairs +wlp_list+, returns a set of
  # the winners in the pairs of the list (with no duplicates).
  def OTLearn.wlp_winners(wlp_list)
    winners = Set.new # Set automatically filters duplicate entries
    wlp_list.each do |wlp|
      winners.add(wlp.winner)
    end
    winners
  end

  # Takes a language in the form of a list of WL pairs (with
  # each represented form of the language appearing as a winner in at least
  # one pair), and returns a list of the winner outputs.
  def OTLearn.convert_wl_pairs_to_learning_data(wl_pairs)
    # Extract the outputs of the grammatical candidates of the language.
    outputs = wlp_winners(wl_pairs).map{|winner| winner.output}
    outputs
  end
end
