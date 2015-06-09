# Author: Bruce Tesar
#
 
require_relative 'competition'
require_relative 'competition_list'
require_relative 'comparative_tableau'
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
    @constraint_list = comp_list.constraint_list
    @hb_flags = Hash.new
    check_harmonic_boundedness
  end

  # Private method, called by +initialize+, to check and record the harmonic
  # boundedness status of each candidate.
  #--
  # @hb_flags[cand.label] is true if cand is harmonically bound; false otherwise.
  def check_harmonic_boundedness
    @original_comp_list.each do |comp|
      comp.each do |cand|
        ct = Comparative_tableau.new("check_with_rcd", @constraint_list)
        winner_comp = construct_competition_with_winner(cand, comp)
        # check to see if winner is possibly optimal
        ct.add_competition(winner_comp)
        rcd_result = Rcd.new(ct)
        # If the CT is inconsistent, then the candidate is harmonically bound
        @hb_flags[cand.label] = !rcd_result.consistent?
      end
    end
  end
  private :check_harmonic_boundedness
  
  # Computes the factorial typology of the list of competitions stored in this
  # object. Each language is represented as a comparative tableau, with a
  # winner-loser pair for each combination of a winner and a possibly optimal
  # competitor. The languages are assigned numeric labels, in the order in
  # which they are generated. An array of the comparative tableaux is returned.
  # 
  # To get a list of the optimal candidates for a particular language,
  # call Comparative_tableau#winners.
  def factorial_typology
    # start with competitions containing only possible optima (non-HB)
    comp_list = non_hb_competition_list
    set_competitions_with_fixed_optima(comp_list)
    # Construct initial language list with a single empty language
    lang_list = [Comparative_tableau.new("", @constraint_list)]
    # Iterate over the competitions
    comp_list.each do |comp|
      lang_list_new = [] # will receive languages with winners from comp added
      lang_list.each do |lang| # for each prior language
        comp.each do |winner| # for each possible winner in the current competition
          # don't include as a winner if explicitly marked to the contrary
          # (factorial typology filtering)
          next if winner.opt_denied?
          lang_new = lang.dup
          winner_comp = construct_competition_with_winner(winner, comp)
          lang_new.add_competition(winner_comp)
          rcd_result = Rcd.new(lang_new)
          # If the new language is consistent, add it to the new language list.
          lang_list_new << lang_new if rcd_result.consistent?
        end
      end
      lang_list = lang_list_new
    end
    # Assign numbered language labels
    lang_label = 0
    lang_list.each{|lang| lang_label+=1; lang.label = "L#{lang_label}"}
    return lang_list
  end

  # Returns a copy of the competition +competition+, altered so that the
  # candidate +candidate_winner+ is the winner.
  # A duplicate is made of each of the candidates so that the altered
  # opt field doesn't affect objects referenced elsewhere.
  def construct_competition_with_winner(candidate_winner, competition)
    winner = candidate_winner.dup
    losers = competition.reject{|c| c==candidate_winner}
    losers = losers.map{|c| c.dup}
    winner.assert_opt; losers.each{|c| c.option_opt}
    new_comp = Competition.new
    new_comp.push(winner)
    losers.each{|loser| new_comp.push(loser)}
    return new_comp
  end

  # Returns true if the candidate labeled +clabel+ is harmonically bounded;
  # returns false otherwise.
  def hbound?(clabel)
    @hb_flags[clabel]
  end

  # Returns the competition list defining the system that is the basis for
  # the typology.
  def competition_list
    @original_comp_list
  end

  # Returns a competition list of the competitions of this factorial
  # typology object, but with all of the harmonically bound candidates
  # removed.
  def non_hb_competition_list
    comp_list_new = Competition_list.new
    comp_list_new.label = @original_comp_list.label
    @original_comp_list.each do |comp|
      comp_new = Competition.new
      comp.each {|cand| comp_new.push(cand) unless hbound?(cand.label)}
      comp_list_new << comp_new
    end
    return comp_list_new
  end

  # Checks each competition in +comp_list+, to see if a candidate has been
  # asserted to be optimal. For each such competition, the candidates
  # are duplicated, and then the non-optimal candidates are set so that
  # optimality is explicitly denied. Thus, when the factorial typology
  # computation skips over (as possible optima) candidates for which optimality
  # is explicitly denied, it will skip all competitors to a candidate for
  # which optimality has been explicitly asserted.
  #
  # Returns true.
  def set_competitions_with_fixed_optima(comp_list)
    comp_list.each do |comp|
      if comp.optima? then
        comp.map!{|cand| cand.dup} #dup candidates so originals aren't altered
        # set each non-optimal candidate so opt is explicitly denied
        comp.each{|cand| cand.deny_opt unless cand.opt?}
      end
    end
    return true
  end

end # class FactorialTypology
