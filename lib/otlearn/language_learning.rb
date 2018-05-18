# Author: Bruce Tesar
#

require_relative 'contrast_pair'
require_relative 'ranking_learning'
require_relative 'grammar_test'
require_relative '../loserselector_by_ranking'
require_relative 'uf_learning'
require_relative 'mrcd'
require_relative 'data_manip'
require_relative '../feature_value_pair'
require_relative 'learning_exceptions'
require_relative 'induction_learning'

module OTLearn

  # A LanguageLearning object instantiates a particular instance of
  # language learning. An instance is created with a set of outputs
  # (the data to be learned from), and a starting grammar (which
  # will likely be altered during the course of learning).
  #
  # The learning proceeds in the following stages, in order:
  # * Phonotactic learning.
  # * Single form learning (one word at a time until no more can be learned).
  # * Repeat until the language is learned or no more progress is made.
  #   * Try a contrast pair; if none are successful, try minimum uf setting.
  #   * If either of these is successful, and the language is not yet learned,
  #     run another round of single form learning.
  # After each stage in which grammar change occurs, the state of
  # the learner is stored and evaluated in a GrammarTest object. These
  # objects are stored in a list, obtainable via #results_list().
  #
  # Learning is initiated upon construction of the object.
  class LanguageLearning

    # Executes learning on +outputs+ with respect to +grammar+, and
    # stores the results in the returned LanguageLearning object.
    def initialize(outputs, grammar)
      @outputs = outputs
      @grammar = grammar
      @results_list = []
      # Convert the outputs to full words, using the grammar,
      # populating the lexicon with the morphemes of the outputs in the process.
      # parse_output() adds the morphemes of the output forms to the lexicon,
      # and constructs a UI correspondence for the input of each word, connecting
      # to the underlying forms of the lexicon.
      @winner_list = @outputs.map{|out| @grammar.system.parse_output(out, @grammar.lexicon)}
      @learning_successful = execute_learning
    end

    # Returns the outputs that were the data for learning.
    def data_outputs() return @outputs end

    # Returns the winners (full candidates) that were used as interpretations of the outputs.
    def data_winners() return @winner_list end

    # Returns the final grammar that was the result of learning.
    def grammar() return @grammar end

    # Returns a boolean indicating if learning was successful.
    def learning_successful?() return @learning_successful end

    # Returns the list of grammar_test objects generated at various stages
    # of learning.
    def results_list()
      @results_list
    end

    # The main, top-level method for executing learning. This method is
    # protected, and called by the constructor #initialize, so learning
    # is automatically executed whenever a LanguageLearning object is
    # created.
    # Returns true if learning was successful, false otherwise.
    def execute_learning
      # Phonotactic learning
      OTLearn::ranking_learning_faith_low(@winner_list, @grammar)
      @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Phonotactic Learning")
      return true if @results_list.last.all_correct?
      # Single form UF learning
      run_single_forms_until_no_change(@winner_list, @grammar)
      @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Single Form Learning")
      return true if @results_list.last.all_correct?
      # Pursue further learning until the language is learned, or no
      # further improvement is made.
      learning_change = true
      while learning_change
        learning_change = false
        # First, try to learn from a contrast pair
        contrast_pair = run_contrast_pair(@winner_list, @grammar, @results_list.last)
        unless contrast_pair.nil?
          @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Contrast Pair Learning")
          learning_change = true
#        else
#          # No suitable contrast pair, so pursue a step of minimal UF learning
#          guy = OTLearn::InductionLearning.new(@winner_list, @grammar, @results_list.last, self)
#          guy.run_induction_learning
#          if guy.change? then
#            learning_change = true
#            @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Minimal UF Learning")
#          end
        end
        # If no change resulted from a contrast pair or from minimal uf learning,
        # no further learning is currently possible, so break out of the loop.
        # Otherwise, check to see if the change completed learning.
        break unless learning_change
        return true if @results_list.last.all_correct?
        # Follow up with another round of single form learning
        change_on_single_forms = run_single_forms_until_no_change(@winner_list, @grammar)
        if change_on_single_forms then
          @results_list << OTLearn::GrammarTest.new(@winner_list, @grammar, "Single Form Learning")
          return true if @results_list.last.all_correct?
        end
      end
      # Return boolean indicating if learning was successful.
      # This should be false, because a "true" would have triggered an earlier
      # return from this method.
      fail if @results_list.last.all_correct?
      return @results_list.last.all_correct?
    end

    # This method processes all of the words in +winners+, one at a time in
    # order, with respect to the grammar +grammar+. Each winner is processed
    # as follows:
    # * Error test the winner: see if it is the sole optimum for the
    #   mismatched input (all unset features assigned opposite their
    #   surface values) using the Faith-Low hierarchy.
    # * Check if the winner is optimal when unset input features are matched
    #   to the output, and if not, find more ranking info.
    # * Attempt to set any unset underlying features of the winner.
    # * For each newly set feature, check for new ranking information.
    # It passes repeatedly through the list of winners until a pass is made
    # with no changes to the grammar.
    # A boolean is returned indicating if the grammar was changed at all
    # during the execution of this method.
    def run_single_forms_until_no_change(winners, grammar)
      grammar_ever_changed = false
      grammar_changed_on_pass = true
      while grammar_changed_on_pass do
        grammar_changed_on_pass = false
        winners.each do |winner|
          # Error test the winner by checking to see if it is the sole
          # optimum for the mismatched input using the Faith-Low hierarchy.
          error_test = OTLearn::GrammarTest.new([winner], grammar)
          # Unless no error is detected, try learning with the winner.
          unless error_test.all_correct? then
            # Check the winner to see if it is the sole optimum for
            # the matched input; if not, more ranking info is gained.
            new_ranking_info = OTLearn::ranking_learning_faith_low([winner], grammar)
            grammar_changed_on_pass = true if new_ranking_info
            # Check the mismatched input for consistency.
            # Unless the mismatched winner is consistent, attempt to set
            # each unset feature of the winner.
            consistency_result = mismatch_consistency_check(grammar, [winner])
            unless consistency_result.grammar.consistent?
              set_feature_list = OTLearn.set_uf_values([winner], grammar)
              grammar_changed_on_pass = true unless set_feature_list.empty?
              # For each newly set feature, check words unfaithfully mapping that
              # feature for new ranking information.
              set_feature_list.each do |set_f|
                OTLearn::new_rank_info_from_feature(grammar, winners, set_f)
              end
            end
          end
        end
        grammar_ever_changed = true if grammar_changed_on_pass
      end
      return grammar_ever_changed
    end

    # Select a contrast pair, and process it, attempting to set underlying
    # features. If any features are set, check for any newly available
    # ranking information.
    # 
    # This method returns the first contrast pair that was able to set
    # at least one underlying feature. If none of the constructed
    # contrast pairs is able to set any features, nil is returned.
    def run_contrast_pair(winner_list, grammar, prior_result)
      # Create an external iterator which calls generate_contrast_pair()
      # to generate contrast pairs.
      cp_gen = Enumerator.new do |result|
        OTLearn::generate_contrast_pair(result, winner_list, grammar, prior_result)
      end
      # Process contrast pairs until one is found that sets an underlying
      # feature, or until all contrast pairs have been processed.
      loop do
        contrast_pair = cp_gen.next
        # Process the contrast pair, and return a list of any features
        # that were newly set during the processing.
        set_feature_list = OTLearn::set_uf_values(contrast_pair, grammar)
        # For each newly set feature, see if any new ranking information
        # is now available.
        set_feature_list.each do |set_f|
          OTLearn::new_rank_info_from_feature(grammar, winner_list, set_f)
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



    # Given a list of words and a grammar, check the word list for
    # consistency with the grammar using MRCD. Any features unset
    # in the lexicon of the grammar are set in the input of a word
    # to the value opposite its output correspondent in the word.
    # The mismatching is done separately for each word (the same unset feature
    # for a morpheme might be assigned different values in the inputs of
    # different words containing that morpheme, depending on what the outputs
    # of those words are).
    # Returns the Mrcd object containing the results.
    # To find out if the word list is consistent with the grammar, call
    # result.grammar.consistent? (where result is the Mrcd object returned
    # by #mismatch_consistency_check).
    def mismatch_consistency_check(grammar, word_list)
      w_list = word_list.map { |winner| winner.dup }
      # Set each word's input so that features unset in the lexicon
      # mismatch their output correspondents. A given output could appear
      # more than once in the mismatch list ONLY if there are suprabinary
      # features (a suprabinary feature can mismatch in more than one way).
      mismatch_list = []
      w_list.map do |word|
        OTLearn::mismatches_input_to_output(word) { |mismatched_word| mismatch_list << mismatched_word }
      end
      # Run MRCD to see if the mismatched candidates are consistent.
      selector = LoserSelector_by_ranking.new(@grammar.system)
      mrcd = Mrcd.new(mismatch_list, grammar, selector)
      return mrcd
    end

    protected :execute_learning, :run_single_forms_until_no_change,
      :run_contrast_pair

  end # class LanguageLearning
  
end # module OTLearn
