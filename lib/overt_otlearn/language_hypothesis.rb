# Author: Crystal Akers
#

require 'REXML/syncenumerator'
require_relative '../hypothesis'
require_relative '../otlearn'
require_relative 'data_manip'
require_relative 'commitment_list'
require_relative 'label_set'
require_relative 'overt_grammar_test'
require_relative '../sf/sf_word'
require_relative '../sf/system'


module Overt_OTLearn

  # A language hypothesis is a grammar hypothesis plus a list of paired overt forms
  # and outputs comprising the committed structural interpretations for the language.
  # Each hypothesis also contains a list of winners, a list of OvertGrammarTest results,
  # and a boolean record of whether the hypothesis has been changed during learning.

  class Language_Hypothesis < Hypothesis

    # Creates a new language hypothesis. If they are not provided as parameters,
    # the lists of commitment pairs, winners, and results are created as empty initial lists.
    #   @commitments stores commitment pairs: [overt form, output].
    #   @winner_list stores full structural descriptions whose outputs are included in
    #     _@commitments_
    #   @results_list stores a history of the language hypothesis' results on Grammar Tests.
    #   The results list is duplicated and extended if the hypothesis branches.
    #   @learning_change stores a boolean for indicating whether the hypothesis has
    #   changed during (some period of) learning.
    def initialize(gram, erc_list=nil, commitments=nil, overt_forms = nil, winner_list=nil, results_list = nil, learning_change = nil, lang_hyp_label = nil)
      super(gram, erc_list)
      if commitments.nil? then
        @commitments = Commitment_List.new
      else
        @commitments = commitments
      end
      if overt_forms.nil? then
        @overt_forms = Array.new
      else
        @overt_forms = overt_forms
      end
      if winner_list.nil? then
        @winner_list = []
      else @winner_list = winner_list
      end
      if results_list.nil? then
        @results_list = []
      else
        @results_list = results_list
      end
      if learning_change.nil? then
        @learning_change = true
      end
      if lang_hyp_label.nil? then
        @lang_hyp_label = String.new
      end
    end

    # Returns the commitments for the language hypothesis.
    def commitments() @commitments end

    # Returns the list of winners for the language hypothesis.
    def winner_list() @winner_list end

    # Returns the results list for the language hypothesis.
    def results_list() @results_list end

    # Returns a boolean representing the learning change for the language hypothesis.
    def learning_change() @learning_change end

    # Sets the value of @learning_change to a boolean
    def hyp_change(boolean)
       @learning_change = boolean
    end

    # Returns the set of overt forms used in commitment pairs in the language hypothesis.
    def overt_forms()@overt_forms end

    # Return the label of the language hypothesis
    def lang_hyp_label() @lang_hyp_label end

    # Returns a copy of the language hypothesis, with a duplicated grammar, erc_list,
    # commitment_pair list, overt_forms list, winner list, and results list, and label.
    def dup
      hyp_dup = super
      winners = []
      @winner_list.each do |win|
        w =  win.dup
        w.sync_with_hypothesis!(hyp_dup)
        winners << w
      end
      label = String.new
      label = @lang_hyp_label.dup
      lang_hyp = Language_Hypothesis.new(hyp_dup.grammar, hyp_dup.erc_list,
       @commitments.dup, @overt_forms.dup, winners, @results_list.dup)
      lang_hyp.lang_hyp_label << label
      return lang_hyp
    end

    # Given a language hypothesis and an overt form, returns a list of all consistent
    # branches from that hypothesis. Each branch begins as a copy of the given language
    # hypothesis, to which a new commitment_pair and winner are added if necessary.
    # The ranking bias flag determines which ranking bias to use: if the flag is nil,
    # the FaithLow bias is used, otherwise the MarkLow bias is used. The flag should
    # be nil except when the Branch method is called after setting a feature.
    def branch(overt_form, ranking_bias_flag)
      branch_list = []
      discards = []
      interpretations = []
      interpretations = system.get_interpretations(overt_form,grammar)
      interpretations.each do |word|
        lang_hyp = self.dup
        # Add a new commitment pair and winner to the branch
        commit_pair = lang_hyp.commitments.add_commitment_pair(word.output)
        lang_hyp.add_winner(word.overt, commit_pair)
        OTLearn::ranking_learning(lang_hyp.winner_list, lang_hyp, ranking_bias_flag)
                  lang_hyp.results_list <<
            Overt_OTLearn::OvertGrammarTest.new(lang_hyp, "Branch committed to #{word.output.to_s} ")
        if lang_hyp.consistent? then
          lang_hyp.hyp_change(true)
          branch_list << lang_hyp
        else
          discards << lang_hyp
        end
      end
      return branch_list, discards
    end

  # Updates the constraint hierarchy in the grammar, regardless of whether the
  # hypothesis is consistent. This update ensures that inconsistent language
  # hypotheses will show which ERCs lead to the inconsistency.
  # An optional block provides the code for generating the updated
  # grammar (some variation of Rcd). If no block is provided, then
  # regular RCD is used (all constraints has high as possible).
  def update_grammar
    if block_given?
      rcd_result = yield(@erc_list)
    else
      rcd_result = Rcd.new(@erc_list)
    end
    @consistent = rcd_result.consistent?
    @grammar.hierarchy = rcd_result.hierarchy
    return rcd_result
  end

    #TODO could change this method so that it takes only the overt form, it looks
    #itself through the commitment list to find the correct output form
    # This method creates a new winner having the same morphword as _overt_form_ and
    # the output from the given _commitment_pair_, then adds the winner to the winner list.
    # The method returns the winner.
    def add_winner(overt_form, commitment_pair)
        prior_winner = existing_winner(overt_form)
        raise "Prior winner exists: #{prior_winner.to_s}" unless prior_winner.nil?
        output = commitment_pair[1].dup
        # Syllables in _output_ are set to the same morpheme as the corresponding
        # syllables in _overt_form_
        gen = REXML::SyncEnumerator.new(overt_form, output.syl_list)
        gen.each do |overt_syl,output_syl|
          output_syl.set_morpheme(overt_syl.morpheme)
        end
        output.morphword = overt_form.morphword
        winner = self.system.parse_output(output, grammar)
        self.winner_list << winner
        return winner
    end

    # This method returns the winner whose morphword matches _overt_form_,
    # if such a winner exists in the language hypothesis; it returns nil otherwise.
    def existing_winner(overt_form)
      match = self.winner_list.find {|winner| winner.morphword == overt_form.morphword}
      if match then
        if match.overt != overt_form then
          raise "Overt form #{overt_form.to_s} doesn't match existing winner #{match.to_s}"
        end
      end
      return match
    end

    # Returns a string containing string representations of the hierarchy, lexicon,
    # ERC list and structural commitment_pair_pairs and results list of this language hypothesis.
    def to_s
      out_str = "HIERARCHY" + "\n"
      out_str += @grammar.hierarchy.to_s + "\n"
            out_str += "LEXICON"+ "\n"
      out_str += @grammar.lexicon.to_s + "\n"
            out_str += "ERC LIST"+ "\n"
      out_str += @erc_list.join("\n")
            out_str += "\n"+ "COMMITMENT PAIRS"+ "\n"
      out_str += @commitments.to_s
            out_str += "\n"+"WINNER LIST"+ "\n"
      out_str += @winner_list.join("\n")
            out_str += "\n"+"RESULTS LIST"+ "\n"
      out_str += @results_list.join("\n")
      out_str
    end

  end # class Language_Hypothesis
end # module Overt_OTLearn
