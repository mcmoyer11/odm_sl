# frozen_string_literal: true

# Author: Bruce Tesar

require_relative 'erc_list'

# FactorialTypology objects summarize typologies of competition lists
# in two ways:
# * Determining which candidates are contenders (possibly optimal).
#   The contenders are obtained via the method #contender_comp_list.
# * Determining the typology of possible languages.
#   The language typology is obtained via method #factorial_typology.
class FactorialTypology
  # The list of competitions with all the candidates
  attr_reader :original_comp_list

  # The list of competitions with only contenders (non-harmonically bound)
  attr_reader :contender_comp_list

  # Returns an object summarizing the factorial typology of the competition
  # list +comp_list+. The harmonic boundedness status of each candidate
  # is computed upon creation of the object. The language typology is
  # computed and returned by the method +factorial_typology+.
  def initialize(comp_list, erc_list_class: ErcList)
    @original_comp_list = comp_list
    @contender_comp_list = []
    @erc_list_class = erc_list_class
    check_harmonic_boundedness
  end

  # Private method, called by #initialize, to check the harmonic boundedness
  # of each candidate, and store the contenders (non-harmonically bound
  # candidates) as a contender competition.
  def check_harmonic_boundedness
    @original_comp_list.each do |comp|
      contenders = []
      comp.each do |winner|
        # if the WL pairs for the winner are consistent, then the winner is
        # a contender.
        erc_list = @erc_list_class.new_from_competition(winner, comp)
        contenders << winner if erc_list.consistent?
      end
      @contender_comp_list << contenders
    end
  end
  private :check_harmonic_boundedness

  # Computes the factorial typology of the list of competitions stored in this
  # object. Each language is represented as a list of winner-loser pairs,
  # one for each combination of a winner and a contending competitor.
  # The languages are assigned numeric labels, in the order in
  # which they are generated. An array of the languages is returned.
  #
  # To get a list of the optimal candidates for a particular language,
  # call OTLearn::wlp_winners(+language+).
  def factorial_typology
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

  # Assign numbered labels to the languages, by the order in which they
  # appear in the language list. Each label is stored as the label
  # attribute of the corresponding language.
  # Returns a reference to the list of languages.
  def label_languages(lang_list)
    lang_label = 0
    lang_list.each do |lang|
      lang_label += 1
      lang.label = "L#{lang_label}"
    end
    lang_list
  end
  protected :label_languages
end
