# Author: Crystal  Akers
#

require_relative '../otlearn/grammar_test'
require_relative '../otlearn/uf_learning'
require_relative '../otlearn/data_manip'
require_relative 'commitment_list'
require_relative '../sf/sf_output'
require_relative '../morph_word'

module Overt_OTLearn

  # An OvertGrammarTest object holds the results of the evaluation of a set
  # of winners with respect to a hypothesis. The tests are initiated by
  # creating an OvertGrammarTest; the constructor takes a list of winners and
  # a hypothesis as parameters.
  #
  # Each winner is a Word, possibly with unset features in the input.
  class OvertGrammarTest < OTLearn::GrammarTest

    # Returns a new OvertGrammarTest, for the provided _winners_, and with
    # respect to the provided _lang_hyp_.
    def initialize(lang_hyp, label="NoLabel")
      super(lang_hyp.winner_list, lang_hyp, label)
      # Dup the language hypothesis, so it can be frozen.
      @l_hyp = lang_hyp.dup
      # Dup the commitments
      @commitments = lang_hyp.commitments.dup
      # Dup the set of overt forms
      @overt_forms = lang_hyp.overt_forms.dup
      # Freeze the test results, so they cannot be accidentally altered later.
      @l_hyp.freeze
      @commitments.each {|c_pair| c_pair.freeze}
      @commitments.freeze
      @overt_forms.each {|overt| overt.freeze}
      @overt_forms.freeze
    end

    def lang_hyp
      return @l_hyp
    end
    # Returns true if
    #   - all winners in the winner list are the sole optima for inputs with all
    #     unset features set to mismatch the surface of the winner.
    #   - no new ranking or lexical information can be learned from the remaining
    #     overt forms without committed outputs
    def all_correct?
      return false unless @failed_winner_info_list.empty?
      return false unless check_overt_forms_for_ranking_info(uncommitted_overts)
      return false unless check_overt_forms_for_lexical_info(uncommitted_overts)
      return true
    end

    # Returns a list of overt forms which do not have committed output interpretations
    def uncommitted_overts
      uncommitted_forms = Array.new
      @overt_forms.each do |overt|
        uncommitted_forms << overt unless @commitments.any? {|c_pair| @commitments.forms_match?(overt, c_pair)}
      end
      return uncommitted_forms
    end

    # For each form in _overt_forms_  checks to see if any optimum has an overt form
    # distinct from that form. If so, returns false because more can be learned
    # about the ranking of this language hypothesis.
    def check_overt_forms_for_ranking_info(overt_forms)
      overt_forms.each do |overt_form|
        input = OTLearn::input_from_lexicon_and_overt(overt_form, @l_hyp.grammar)
        competition = @l_hyp.system.gen(input)
        # Find the most harmonic candidates
        mh = MostHarmonic.new(competition, @l_hyp.grammar.hierarchy)
        commitment = @l_hyp.commitments.existing_commitment_pair(overt_form)
        # Return if new ranking info is available (if any optimum does not have the same overt form)
        return false if mh.any? {|cand| cand.overt.to_s != overt_form.to_s}
      end
      return true
    end

    # For each form in _overt_forms_ checks to see if any new lexical information
    # could be learned from that form. If so, returns false.
    def check_overt_forms_for_lexical_info(overt_forms)
      overt_forms.each do |overt|
        # Check that no new lexical information is available
        OTLearn::mismatches_input_to_overt(@l_hyp.grammar, overt) do |mismatched_input|
            competition = @l_hyp.system.gen(mismatched_input)
            mh = MostHarmonic.new(competition, @l_hyp.grammar.hierarchy)
            # If any optimum has an *overt* form distinct from _overt_, an unset feature
            # can be set.
            return false if mh.any? {|cand| cand.overt.to_s != overt.to_s}
          end
      end
        return true
    end

  end # class OvertGrammarTest

end # module Overt_OTLearn
