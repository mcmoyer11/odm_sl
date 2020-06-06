# frozen_string_literal: true

# Author: Bruce Tesar

# Generates a language, specifically an array of optimal candidates for
# the competitions of a competition list, with respect to a hierarchy.
# The eval function determining the details of optimization with respect
# to a hierarchy is provided to the LanguageGenerator constructor.
# Generation of a language for a given competition list and hierarchy is
# performed via a call to the method #generate_language.
class LanguageGenerator
  # Returns a new generator object, which will compute optima based on
  # +eval+, the provided candidate evaluation and comparison function.
  # :call-seq:
  #   LanguageGenerator.new(eval) -> generator
  def initialize(eval)
    @eval = eval
  end

  # Generates an array of candidates, where each candidate is an
  # optimum for one of the competitions in +competition_list+ with
  # respect to +hierarchy+.
  #
  # NOTE: if more than one candidate in a competition ties for optimality,
  # then all optima will appear in the language (array of candidates).
  def generate_language(competition_list, hierarchy)
    language = []
    competition_list.each do |comp|
      # add the list of optima to the language
      language << @eval.find_optima(comp, hierarchy)
    end
    # language is currently an array of arrays (one array for each
    # competition); flatten it to just an array of candidates.
    language.flatten
  end
end
