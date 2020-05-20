# Author: Bruce Tesar
# frozen_string_literal: true

require_relative 'erc_list'
require_relative 'win_lose_pair'
require_relative 'rcd'

# FactorialTypology objects summarize typologies of competition lists
# in two ways:
# * Determining which candidates are harmonically bound, and which are
#   possibly optimal.
# * Determining the typology of possible languages.
# The harmonic boundedness of a candidate is obtained via +hbound?+.
# The language typology is obtained via method +factorial_typology+.
#
# Candidates are identified by their labels; the user has the responsibility
# of ensuring that all candidate labels are unique.
class FactorialTypology
  # Returns an object summarizing the factorial typology of the competition
  # list +comp_list+. The harmonic boundedness status of each candidate
  # is computed upon creation of the object. The language typology is
  # computed and returned by the method +factorial_typology+.
  def initialize(comp_list)
    @original_comp_list = comp_list
    @hb_flags = {}
    check_harmonic_boundedness
  end

  # Private method, called by +initialize+, to check and record the harmonic
  # boundedness status of each candidate.
  #--
  # @hb_flags[cand.label] is true if cand is harmonically bound;
  # false otherwise.
  def check_harmonic_boundedness
    @original_comp_list.each do |comp|
      comp.each do |winner|
        # if WL pairs with cand are inconsistent,
        # then cand is harmonically bound
        losers = comp.reject { |c| c == winner }
        erc_list = winner_loser_pairs(winner, losers)
        @hb_flags[winner.label] = !erc_list.consistent?
      end
    end
  end
  private :check_harmonic_boundedness

  # Returns an Erc_list of winner-loser pairs for +winner+ paired with
  # each candidate in +losers+.
  def winner_loser_pairs(winner, losers)
    # Construct a list of winner-loser pairs, one per loser
    wl_list = Erc_list.new
    losers.each do |loser|
      pair = Win_lose_pair.new(winner, loser)
      wl_list.add(pair)
    end
    wl_list
  end
  protected :winner_loser_pairs

  # Computes the factorial typology of the list of competitions stored in this
  # object. Each language is represented as a list of winner-loser pairs,
  # one for each combination of a winner and a possibly optimal
  # competitor. The languages are assigned numeric labels, in the order in
  # which they are generated. An array of the languages is returned.
  #
  # To get a list of the optimal candidates for a particular language,
  # call OTLearn::wlp_winners(+language+).
  def factorial_typology
    # start with competitions containing only possible optima (non-HB)
    comp_list = non_hb_competition_list
    # Construct initial language list with a single empty language
    lang_list = [Erc_list.new]
    # Iterate over the competitions
    comp_list.each do |comp|
      lang_list_new = [] # will receive languages with winners from comp added
      lang_list.each do |lang| # for each prior language
        comp.each do |winner| # test each candidate as a winner
          lang_new = lang.dup
          losers = comp.reject { |c| c == winner }
          new_pairs = winner_loser_pairs(winner, losers)
          lang_new.add_all(new_pairs)
          rcd_result = Rcd.new(lang_new)
          # If the new language is consistent, add it to the new language list.
          lang_list_new << lang_new if rcd_result.consistent?
        end
      end
      lang_list = lang_list_new
    end
    # Assign numbered language labels
    lang_label = 0
    lang_list.each do |lang|
      lang_label += 1
      lang.label = "L#{lang_label}"
    end
    lang_list
  end

  # Returns true if the candidate labeled +clabel+ is harmonically bounded;
  # returns false otherwise.
  def hbound?(clabel)
    @hb_flags[clabel]
  end

  # Returns the competition list extensionally defining the system that is
  # the basis for the typology.
  def competition_list
    @original_comp_list
  end

  # Returns an array of the competitions of this factorial
  # typology object, but with all of the harmonically bound candidates
  # removed.
  def non_hb_competition_list
    comp_list_new = []
    @original_comp_list.each do |comp|
      comp_new = []
      comp.each { |cand| comp_new.push(cand) unless hbound?(cand.label) }
      comp_list_new << comp_new
    end
    comp_list_new
  end
end
