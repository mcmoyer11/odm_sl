# frozen_string_literal: true

# Author: Bruce Tesar

require_relative 'erc_list'
require_relative 'harmonic_bound_filter'
require_relative 'ident_violation_analyzer'

# FactorialTypology objects summarize typologies of competition lists
# in two ways:
# * Determining which candidates are contenders (possibly optimal).
#   The contenders are obtained via the method #contender_comp_list.
# * Determining the typology of possible languages.
#   The language typology is obtained via method #factorial_typology.
# Each language is represented as a list of winner-loser pairs,
# one for each combination of a winner and a contending competitor.
# The languages are assigned numbered labels, in the order in
# which they are generated.
#
# To get a list of the optimal candidates for a particular language,
# call OTLearn::wlp_winners(+language+).
class FactorialTypology
  # The list of competitions with all the candidates
  attr_reader :original_comp_list

  # The list of competitions with only contenders (non-harmonically bound)
  attr_reader :contender_comp_list

  # The factorial typology of the list of competitions.
  # Each language is represented as a list of winner-loser pairs,
  # one for each combination of a winner and a contending competitor.
  attr_reader :factorial_typology

  # Returns an object summarizing the factorial typology of the parameter
  # +competition_list+. The parameter +competition_list+ must respond to
  # the method #each.
  #
  # :call-seq:
  #   FactorialTypology.new(competition_list) -> FactorialTypology
  #--
  # erc_list_class and hbound_filter are dependency injections, mostly
  # for testing.
  def initialize(competition_list, erc_list_class: ErcList,
                 hbound_filter: HarmonicBoundFilter.new,
                 viol_analyzer_class: IdentViolationAnalyzer)
    @erc_list_class = erc_list_class
    @harmonic_bound_filter = hbound_filter
    @viol_analyzer_class = viol_analyzer_class
    @original_comp_list = competition_list
    @contender_comp_list = []
    filter_harmonically_bounded
    ident_viol_candidates_check
    @factorial_typology = compute_typology
  end

  # Private method, called by #initialize, to filter out collectively
  # harmonically bound candidates, creating a list of competitions consisting
  # only of contenders.
  def filter_harmonically_bounded
    @original_comp_list.each do |comp|
      contenders = @harmonic_bound_filter.remove_collectively_bound(comp)
      @contender_comp_list << contenders
    end
  end
  private :filter_harmonically_bounded

  # Checks the competitions of contenders, raises an exception if two or more
  # competing contenders are found with identical constraint violation
  # profiles.
  def ident_viol_candidates_check
    msg = 'competing contenders with identical violation profiles'
    @contender_comp_list.each do |comp|
      analysis = @viol_analyzer_class.new(comp)
      raise "FactorialTypology: #{msg}" if analysis.ident_viol_candidates?
    end
  end
  private :ident_viol_candidates_check

  # Computes the factorial typology, returning an array of Erc lists.
  def compute_typology
    # Construct initial language list with a single empty language
    lang_list = [@erc_list_class.new]
    # Iterate over the competitions
    contender_comp_list.each do |competition|
      lang_list_new = [] # will receive languages with winners from comp added
      lang_list.each do |lang| # for each prior language
        # test each candidate as a possible winner with the existing language.
        competition.each do |winner| # test each candidate as a winner
          lang_new = lang.dup
          new_pairs = @erc_list_class.new_from_competition(winner, competition)
          lang_new.add_all(new_pairs)
          # If the new language is consistent, add it to the new language list.
          lang_list_new << lang_new if lang_new.consistent?
        end
      end
      lang_list = lang_list_new
    end
    label_languages(lang_list)
    lang_list
  end
  private :compute_typology

  # Assign numbered labels to the languages, by the order in which they
  # appear in the language list. Each label is stored as the label
  # attribute of the corresponding language.
  # Returns a reference to the list of languages.
  #
  # Example: The label for the first language is L1.
  def label_languages(lang_list)
    lang_label = 0
    lang_list.each do |lang|
      lang_label += 1
      lang.label = "L#{lang_label}"
    end
    lang_list
  end
  private :label_languages
end
