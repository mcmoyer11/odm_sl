# Author: Crystal Akers
#

require_relative '../otlearn/contrast_pair'
require_relative '../otlearn/ranking_learning'
require_relative '../otlearn/grammar_test'
require_relative '../otlearn/rcd_bias_low'
require_relative '../otlearn/uf_learning'
require_relative '../morph_word'
require_relative 'overt_grammar_test'
require_relative 'label_set'
require_relative 'language_hypothesis'
require 'facets/array/product' # Adds cartesian product to class Array.
require 'set'

module Overt_OTLearn

  # A  OvertLanguageLearning object instantiates a particular instance of
  # language learning. An instance is created with a set of overt forms
  # (the data to be learned from), and a starting language hypothesis (which
  # will likely be altered and branched during the course of learning).
  #
  # The learning proceeds in the following stages, in order:
  # * Phonotactic learning.
  # * Single form learning (one word at a time until no more can be learned).
  # * Repeat until the language is learned or no more progress is made.
  #   * Try a contrast pair; if none are successful, try minimum uf setting.
  #   * If either of these is successful, and the language is not yet learned,
  #     run another round of single form learning.
  # After each stage in which hypothesis change occurs, the state of
  # the learner is stored and evaluated in an OvertGrammarTest object. These
  # objects are stored in a list, obtainable via #results_list().
  #
  # Learning is initiated upon construction of the object.
  class OvertLanguageLearning

    attr_reader :labels, :letter, :lang_hyp_list, :discards, :results_list

    # Executes learning on _overt_forms_ with respect to _language_hypothesis_, and
    # stores the results in the returned OvertLanguageLearning object.
    def initialize(overt_forms, language_hypothesis)
      # List of overt forms provided as data to the learner
      @overt_forms = overt_forms
      # List of consistent language hypotheses
      @lang_hyp_list = []
      @lang_hyp_list << language_hypothesis
      # List of discarded, inconsistent language hypotheses
      @discards = []
      # Stores the results for learning across all language hypotheses.
      @results_list = []
      # Stores the label hashes associated with the overt forms.
      @labels = Label_set.new
      # Stores the letter to be associated with the next new label hash
      @letter = "A"
      @learning_successful = execute_learning
    end

    # Returns the overt forms that were the data for learning.
    def data_overt_forms() return @overt_forms end

    # Returns the list of language hypotheses that are the result of learning.
    def lang_hyp_list() return @lang_hyp_list end

    # Returns the list of grammar_test objects generated at various stages
    # of learning.
    def results_list()  @results_list end

    # Returns a boolean indicating if learning was successful.
    def learning_successful?() return @learning_successful end

    #Returns the list of discarded language hypotheses.
    def discards() @discards end

    # The main, top-level method for executing learning. This method is
    # protected, and called by the constructor #initialize, so learning
    # is automatically executed whenever an  OvertLanguageLearning object is
    # created.
    # Returns true if learning was successful, false otherwise.
    def execute_learning
      # Phonotactic learning
      puts "Phonotactic learning"
      phonotactic_learning(@overt_forms, @lang_hyp_list)
      @results_list << ["Phonotactic Learning - #{lang_sim_results(@lang_hyp_list)}", learning_completed?]
      return true if learning_completed? == true
      # Single form UF learning
      puts "single form learning"
      run_single_forms_until_no_change(@overt_forms, @lang_hyp_list)
      @results_list << ["Single Form Learning - #{lang_sim_results(@lang_hyp_list)}", learning_completed?]
      return true if learning_completed? == true
      # Pursue further learning until the language is learned, or no
      # further improvement is made.
      puts "Further learning"
      further_learning()
      @results_list << ["Further Learning - #{lang_sim_results(@lang_hyp_list)}", learning_completed?]
      return true if learning_completed? == true
      # It's possible that one consistent hypothesis has learned the language, but no others
      # have. Consider learning successful if this is the case.
      return true if @lang_hyp_list.any? {|lang_hyp| lang_hyp.results_list.last.all_correct?}
      # Return boolean indicating if learning was successful.
      # This should be false, because a "true" would have triggered an earlier
      # return from this method.
      fail if learning_completed? == true
      return learning_completed?
    end

    # This method returns true if learning is complete; that is, if the last grammar
    # test for each language hypothesis is all correct.
    def learning_completed?()
      @lang_hyp_list.each do |lang_hyp|
        # Return false unless the last grammar test for the language hypothesis is
        # all correct.
        return false unless lang_hyp.results_list.last.all_correct?
      end
      return true
    end

    def lang_sim_results(successful_hyps)
      results = String.new
      results += "#{successful_hyps.size} consistent hyps: "
      successful_hyps.each {|hyp| results += hyp.lang_hyp_label.to_s + " - " }
      results += " #{@discards.size} inconsistent hyps: "
      @discards.each {|hyp| results += hyp.lang_hyp_label.to_s + " - "}
      return results
    end

    # Tests each overt form against each language hypothesis until all language
    # hypotheses cycle through all overt forms without making any learning changes.
    def phonotactic_learning(overt_forms, lang_hyp_list)
      ranking_bias = nil   # FaithLow ranking bias
      l_hyp_list = lang_hyp_list
      while l_hyp_list.any? {|l_hyp| l_hyp.learning_change == true}
        # changed_hyps: to be tested against each overt form
        # @lang_hyp_list: unchanged hyps; not to be tested again
        changed_hyps, @lang_hyp_list = l_hyp_list.partition do
          |l_hyp| l_hyp.learning_change
        end
        overt_forms.each do |overt|
          l_hyp_list = changed_hyps
          changed_hyps = []
          until l_hyp_list.empty? do
            lang_hyp = l_hyp_list.shift
            # Add the complete list of overt forms to _lang_hyp_. The overt forms are used
            # by OvertGrammarTest to determine whether anything can be learned from
            # overt forms without committed outputs.
            @overt_forms.each { |o| lang_hyp.overt_forms << o } if lang_hyp.overt_forms.empty?
            # Reset to unchanged by learning
            lang_hyp.hyp_change(false)
            input = OTLearn::input_from_overt(overt)
            competition = lang_hyp.system.gen(input)
            # Find the most harmonic candidates
            mh = MostHarmonic.new(competition, lang_hyp.grammar.hierarchy)
            commitment = lang_hyp.commitments.existing_commitment_pair(overt)
            if commitment then
              # If any optimum has an *output* distinct from the _commitment_ output,
              # perform ranking learning.
              if mh.any? {|cand| !lang_hyp.commitments.forms_match?(cand.output, commitment)} then
                OTLearn::ranking_learning(lang_hyp.winner_list, lang_hyp, ranking_bias)
                lang_hyp.hyp_change(true)
              end
              # Add lang_hyp to changed_hyps list to be tested against the next
              # overt form if it's consistent.
              if lang_hyp.consistent? then
                changed_hyps << lang_hyp
              else
                @discards << lang_hyp
              end
            else # No existing commitment
              # If any optimum has an *overt* form distinct from _overt_form_, create
              # new language hypothesis branches and add the returned, consistent branches to
              # _changed_hyps_ (inconsistent branches go directly to @discards).
              # Otherwise, add the language hypothesis to _changed_hyps_ to be
              # tested against the next overt form.
              if mh.any? {|cand| cand.overt.to_s != overt.to_s} then
                branch_list = extend_branches(lang_hyp, overt)
                branch_list.each {|branch| changed_hyps << branch}
                add_branch_info_to_sim_results(changed_hyps, l_hyp_list, lang_hyp, overt)
              else
                changed_hyps << lang_hyp
              end
            end
          end #until
        end
        l_hyp_list << changed_hyps.shift until changed_hyps.empty?
      end #
      l_hyp_list.each do |l_hyp|
        l_hyp.results_list << Overt_OTLearn::OvertGrammarTest.new(l_hyp, "Phonotactic Learning")
        @lang_hyp_list << l_hyp
      end
      return
    end

    #Extends branches from a lang hyp for a given overt form
    def extend_branches(lang_hyp, overt)
    br_list, discards = lang_hyp.branch(overt, ranking_bias=nil)
    hyp_list = []
    br_list.each {|hyp| hyp_list << hyp}
    discards.each {|hyp| hyp_list << hyp}
    # Update label for each hyp
    hyp_list.each do |hyp|
      @letter = @labels.update_lang_hyp_label(overt, hyp, @letter)
    end
    # Add all inconsistent branches to _@discards_
    discards.each {|hyp| @discards << hyp}
    # Return the list of consistent branches
    return br_list
    end

    # This method processes all of the overt forms in _overt_forms_, one at a time
    # in order, with respect to each language hypothesis in _l_hyp_list_.
    # Each overt form is processed as follows:
    # * Attempt to find new ranking info
    #   - If there's an existing commitment but no winner, create a new winner.
    #   - Check if the winner is optimal when unset input features are matched
    #     to the output, and if not, find more ranking info.
    #   - If there's no existing commitment, check if any optimum differs from
    #     _overt_form_ in string representation. Branch as required.
    # * If a winner exists, attempt to set any of its unset underlying features.
    # * For each newly set feature, check for new ranking information.
    # It passes repeatedly through the list of overt forms until a pass is made
    # with no changes to the language hypothesis.
    # The language hypothesis's constraint hierarchy is updated with
    # the Faith-Low version of RCD.
    # If the language hypothesis is consistent, it is added back to @lang_hyp_list.
    def run_single_forms_until_no_change(overt_forms, l_hyp_list)
      hyp_list = []
      until l_hyp_list.empty? do
        GC.start
        lang_hyp = l_hyp_list.shift
        # TODO add in - attempt to learn only if the lang hasn't been completely learned yet
        lang_hyp.hyp_change(true)
        skip_lang_hyp = false
        while lang_hyp.learning_change == true do
          break if skip_lang_hyp
          lang_hyp.hyp_change(false)
          set_feature_list = []
          # Test each overt form against the hypothesis, first checking for errors, and then
          # trying to set unset features in the form.
          overt_forms.each do |overt|
            break if skip_lang_hyp
            # Check for an existing structural commitment for _overt_
            commitment = lang_hyp.commitments.existing_commitment_pair(overt)
            if commitment then
              # Check for a winner associated with the overt form, and create a new
              # winner if one does not already exist; doing so will populate the lexicon
              # with morphemes not presently in the lexicon.
              winner = lang_hyp.existing_winner(overt)
              if winner.nil? then
                winner = lang_hyp.add_winner(overt, commitment)
              end
              # Check if the winner is actually optimal when matched to the
              # output; if not, attempt to learn more ranking info.
              new_ranking_info = OTLearn::ranking_learning_faith_low([winner], lang_hyp)
              lang_hyp.hyp_change(true) if new_ranking_info
              # If lang_hyp is consistent, attempt to set the unset features of
              # the winner's UFs. Otherwise, add lang_hyp to @discards, and skip
              # attempts at any further learning with it.
              if lang_hyp.consistent? then
                GC.start
                new_set_features = OTLearn.set_uf_values([winner], lang_hyp)
                set_feature_list.concat(new_set_features)
                unless new_set_features.empty? then
                  lang_hyp.hyp_change(true)
                  lang_hyp.results_list << Overt_OTLearn::OvertGrammarTest.new(lang_hyp, "Single Form Learning- #{overt.morphword.to_s} set: #{new_set_features.each {|feat| feat.to_s }}")
                end
              else
                skip_lang_hyp = true
                lang_hyp.results_list << Overt_OTLearn::OvertGrammarTest.new(lang_hyp, "Single Form Learning")
                @discards << lang_hyp
              end
            else # No existing commitment
              add_morphemes_to_lexicon(lang_hyp, overt)
              input = OTLearn::input_from_lexicon_and_overt(overt, lang_hyp.grammar)
              competition = lang_hyp.system.gen(input)
              mh = MostHarmonic.new(competition, lang_hyp.grammar.hierarchy)
              # If any optimum has an *overt* form distinct from _overt_, create
              # new language hypothesis branches and add the consistent ones back to
              # _l_hyp_list_.
              if mh.any? {|cand| cand.overt.to_s != overt.to_s} then
                branch_list = extend_branches(lang_hyp, overt)
                branch_list.each {|branch| l_hyp_list << branch}
                add_branch_info_to_sim_results(hyp_list, l_hyp_list, lang_hyp, overt)
                # Quit learning about this hypothesis because it has branched
                skip_lang_hyp = true
              end
              # If the hyp hasn't branched, check if any unset features have
              # the potential to be set.
              unless skip_lang_hyp
                GC.start
                OTLearn::mismatches_input_to_overt(lang_hyp.grammar, overt) do |mismatched_input|
                  break if skip_lang_hyp
                  competition = lang_hyp.system.gen(mismatched_input)
                  mh = MostHarmonic.new(competition, lang_hyp.grammar.hierarchy)
                  # If any optimum has an *overt* form distinct from _overt_, an unset feature
                  # can be set. Create new language hypothesis branches and add
                  # the consistent ones back to_l_hyp_list_.
                  if mh.any? {|cand| cand.overt.to_s != overt.to_s} then
                    branch_list = extend_branches(lang_hyp, overt)
                    branch_list.each {|branch| l_hyp_list << branch}
                    add_branch_info_to_sim_results(hyp_list, l_hyp_list, lang_hyp, overt)
                    # Quit learning about this hypothesis because it has branched
                    skip_lang_hyp = true
                  end
                end
              end
            end # if commitment then
          end # overt_forms.each
          unless skip_lang_hyp
            # For each newly set feature, check winners in _lang_hyp_ that unfaithfully
            # map that feature for new ranking information.
            GC.start
            set_feature_list.each do |set_f|
              if OTLearn::new_rank_info_from_feature(lang_hyp, lang_hyp.winner_list, set_f) then
                lang_hyp.hyp_change(true)
              end
            end
          end #unless
        end # while
        # Once there are no more learning changes on this hyp, add it to the hyp_list
        # if it is still consistent; otherwise, discard it.
        unless skip_lang_hyp
          lang_hyp.update_grammar {|ercs| OTLearn::RcdFaithLow.new(ercs)}
          lang_hyp.results_list << Overt_OTLearn::OvertGrammarTest.new(lang_hyp, "End of Single Form Learning")
          hyp_list << lang_hyp if lang_hyp.consistent?
          @discards << lang_hyp unless lang_hyp.consistent?
        end
      end #until
      @lang_hyp_list << hyp_list.shift until hyp_list.empty?
    end

    # For any morphemes not currently in the lexicon, create new entries, with
    # the same number of syllables as in the output, and all features unset.
    def add_morphemes_to_lexicon(lang_hyp, overt)
      mw = overt.morphword
      mw.each do |m|
        unless lang_hyp.grammar.lexicon.any?{|entry| entry.morpheme==m} then
          under = Underlying.new
          overt.each_syllable do |syl|
            if syl.morpheme == m then
              under << SF::Syllable.new.set_morpheme(m)
            end
          end
          lang_hyp.grammar.lexicon << Lexical_Entry.new(m,under)
        end
      end
    end

    # Adds to the simulation's results list an entry recording the creation of
    # a new branch.
    def add_branch_info_to_sim_results(hyp_list1, hyp_list2, lang_hyp, overt)
      simultaneous_hyps = []
      hyp_list1.each {|h| simultaneous_hyps << h}
      hyp_list2.each {|h| simultaneous_hyps << h}
      label = lang_hyp.lang_hyp_label
      @results_list << ["#{label.to_s} branches for #{overt.to_s}: #{lang_sim_results(simultaneous_hyps)}"]
    end

    # Pursues further learning until each language hypothesis has learned the language
    # or until no further improvements can be made in any language hypothesis.
    def further_learning()
      hyp_list = []
      until @lang_hyp_list.empty? do
        GC.start
        lang_hyp = @lang_hyp_list.shift
        learning_change = true
        while learning_change
          GC.start
          learning_change = false
          # First, try to learn from a contrast pair
          contrast_pair = run_contrast_pair(lang_hyp.winner_list, lang_hyp, lang_hyp.results_list.last, strict=true)
#          if contrast_pair.nil? then
#            contrast_pair = run_contrast_pair(lang_hyp.winner_list, lang_hyp, lang_hyp.results_list.last, strict=false)
#          end
#          GC.start
          unless contrast_pair.nil?
            cp0 = contrast_pair[0].morphword.to_s
            cp1 = contrast_pair[1].morphword.to_s
            lang_hyp.results_list << Overt_OTLearn::OvertGrammarTest.new(lang_hyp, "Contrast Pair Learning - #{cp0}-#{cp1}")
            learning_change = true
          else
            # No suitable contrast pair, so pursue a step of minimal UF learning
            GC.start
            set_feature = run_minimal_uf_for_failed_winner(lang_hyp.winner_list, lang_hyp, lang_hyp.results_list.last)
            unless set_feature.nil?
              lang_hyp.results_list << Overt_OTLearn::OvertGrammarTest.new(lang_hyp, "Minimal UF Learning: #{set_feature.to_s}")
              learning_change = true
            end
          end
          # If no change resulted from a contrast pair or from minimal uf learning,
          # no further learning is currently possible; cease learning attempts.
          # Otherwise, check to see if the change completed learning. If not,
          # follow up with another round of single form learning. (Any consistent
          # language hypotheses remaining after single form learning will be
          # added to _@lang_hyp_list_
            if learning_change == true then
              # Follow up with another round of single form learning if the language 
              # hasn't yet been learned. (Any consistent language hypotheses
              # remaining after single form learning will be added to the end of
              # _@lang_hyp_list_)
              if lang_hyp.results_list.last.all_correct?
                @lang_hyp_list << lang_hyp
              else
               run_single_forms_until_no_change(@overt_forms, [lang_hyp])
              end
              break
            else
              hyp_list << lang_hyp if lang_hyp.consistent?
              @discards << lang_hyp unless lang_hyp.consistent?
            end
        end #while
      end #until
      @lang_hyp_list << hyp_list.shift until hyp_list.empty?
      return
    end

    # Select a contrast pair, and process it, attempting to set underlying
    # features. If any features are set, check for any newly available
    # ranking information.
    #
    # This method returns the first contrast pair that was able to set
    # at least one underlying feature. If none of the constructed
    # contrast pairs is able to set any features, nil is returned.
    def run_contrast_pair(winner_list, hyp, prior_result, strict)
      # Create an external iterator which calls generate_contrast_pair()
      # to generate contrast pairs.
      cp_gen = Enumerator.new do |result|
        if strict then
          OTLearn::generate_contrast_pair(result, winner_list, hyp, prior_result)
        else
          generate_all_contrast_pairs(result, winner_list, hyp, prior_result)
        end
      end
      # Process contrast pairs until one is found that sets an underlying
      # feature, or until all contrast pairs have been processed.
      loop do
        contrast_pair = cp_gen.next
        # Process the contrast pair, and return a list of any features
        # that were newly set during the processing.
        set_feature_list = OTLearn::set_uf_values(contrast_pair, hyp)
        # For each newly set feature, see if any new ranking information
        # is now available.
        set_feature_list.each do |set_f|
          OTLearn::new_rank_info_from_feature(hyp, winner_list, set_f)
        end
        # If an underlying feature was set, return the contrast pair.
        # Otherwise, keep processing contrast pairs.
        return contrast_pair unless set_feature_list.empty?
      end
      # No contrast pairs were able to set any features; return nil.
      # NOTE: loop silently rescues StopIteration, so if cp_gen runs out
      #       of contrast pairs, loop simply terminates, and execution continues
      #       below it.
      return nil
    end

  def generate_all_contrast_pairs(cp_return, winners, hyp, test_result=nil)
    test_result ||= GrammarTest.new(winners, hyp)
    # The failed winners of the test are connected to a different
    # lexicon. Make duplicates of the failed winners, and synchronize
    # them with _hyp_.
    f_winners = test_result.failed_winners.map do |winner|
      winner.dup.sync_with_hypothesis!(hyp)
    end
    # For each failed winner, look for all contrast pairs
    f_winners.each do |failed_winner|
      OTLearn::match_input_to_uf!(failed_winner)
      failed_winner.morphword.each do |morph|
        all_containing_words = []
        c_words = OTLearn::find_morphemes_in_words(winners)[morph]
        c_words = c_words.delete_if do |cword|
        cword.morphword == failed_winner.morphword
        end
        c_words.each {|cw| all_containing_words << cw}
        all_containing_words.each do |word|
            cp = OTLearn::ContrastSet.new([failed_winner,word])
            cp_return.yield cp
        end
      end
    end
    # TODO: improve the logic for words with greater than two morphemes,
    #       to avoid duplication of words sharing more than one morpheme
    #       with the failed winner.
  end


    def run_minimal_uf_for_failed_winner(winner_list, lang_hyp, prior_result)
      fw_list = prior_result.failed_winners
      set_feature = nil
      fw_list.each do |failed_winner_orig|
        failed_winner = failed_winner_orig.dup.sync_with_hypothesis!(lang_hyp)
        set_feature = select_most_restrictive_uf(failed_winner, lang_hyp)
        break unless set_feature.nil?
      end
      unless set_feature.nil?
        OTLearn::new_rank_info_from_feature(lang_hyp, lang_hyp.winner_list, set_feature)
      end
      return set_feature
    end

    # Sets the minimum number of uf features needed to make the winner
    # able to pass extended error-checking (with all unset features given
    # input values opposite of their output values).
    def select_most_restrictive_uf(failed_winner, main_hypothesis)
      # Find the unset underlying feature instances
      unset_uf_features = OTLearn::find_unset_features_in_words([failed_winner],main_hypothesis)
      # Set, in turn, each unset feature to match its output correspondent.
      # For each case, test to see if the single additional set feature
      # results in the word passing extended error-checking.
      unset_uf_features.each do |ufeat|
        # set the underlying feature to the output value
        out_feat_inst = failed_winner.out_feat_corr_of_uf(ufeat)
        ufeat.value = out_feat_inst.value
        # Test the word for consistency with all other features mismatching
        # the output.
        fw_test = OTLearn::GrammarTest.new([failed_winner], main_hypothesis)
        # If the change passes the test, return with the UF value still set;
        # otherwise, reset the underlying feature to be unset.
        if fw_test.all_correct? then
          return ufeat # TODO: store, then check if more than one feature gives all_correct
        else
          ufeat.value = nil # unset the feature
        end
      end
      # TODO: generalize from one set feature to minimum number
      return nil
    end

    protected :execute_learning, :run_single_forms_until_no_change,
      :run_contrast_pair, :run_minimal_uf_for_failed_winner,
      :select_most_restrictive_uf

  end # class OvertLanguageLearning

end # module Overt_OTLearn

