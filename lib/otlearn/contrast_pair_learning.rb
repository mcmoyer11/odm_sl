# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/contrast_pair'
require 'otlearn/contrast_pair_step'
require 'otlearn/uf_learning'
require 'otlearn/paradigm_erc_learning'
require 'otlearn/grammar_test'

module OTLearn
  # Instantiates contrast pair learning. Any results of learning are
  # realized as side effect changes to the grammar.
  class ContrastPairLearning
    # The paradigmatic ERC learner. Default: ParadigmErcLearning.new
    attr_accessor :para_erc_learner

    # Constructs a contrast pair learning object.
    # :call-seq:
    #   ContrastPairLearning.new -> cp_learner
    #--
    # learning_module and grammar_test_class are dependency injections used
    # for testing.
    # * learning_module - the module containing #generate_contrast_pair
    #   and #set_uf_values.
    # * grammar_test_class - the class of the object used to test
    #   the grammar. Used for testing (dependency injection).
    def initialize(grammar_test_class: OTLearn::GrammarTest,
                   learning_module: OTLearn)
      @learning_module = learning_module
      @grammar_test_class = grammar_test_class
      @para_erc_learner = ParadigmErcLearning.new
    end

    # Select a contrast pair, and process it, attempting to set underlying
    # features. If any features are set, check for any newly available
    # ranking information. Returns the contrast pair, if one was found,
    # and returns nil otherwise.
    def run(output_list, grammar)
      # Test the words to see which ones currently fail
      winner_list = output_list.map do |out|
        grammar.parse_output(out)
      end
      prior_result = @grammar_test_class.new(output_list, grammar)
      # Create an external iterator which calls generate_contrast_pair()
      # to generate contrast pairs.
      contrast_pair = nil
      set_feature_list = []
      cp_gen = Enumerator.new do |result|
        @learning_module.generate_contrast_pair(result, winner_list,
                                                grammar, prior_result)
      end
      # Process contrast pairs until one is found that sets an underlying
      # feature, or until all contrast pairs have been processed.
      # NOTE: loop silently rescues StopIteration, so if cp_gen runs out
      #       of contrast pairs, loop simply terminates, and execution
      #       continues below it.
      loop do
        contrast_pair = cp_gen.next
        # Process the contrast pair, and return a list of any features
        # that were newly set during the processing.
        set_feature_list = @learning_module.set_uf_values(contrast_pair,
                                                          grammar)
        # If an underlying feature was set, exit the loop.
        # Otherwise, continue processing contrast pairs.
        break unless set_feature_list.empty?
      end
      # For each newly set feature, see if any new ranking information
      # is now available.
      set_feature_list.each do |set_f|
        @para_erc_learner.run(set_f, grammar, output_list)
      end
      # No successful contrast pair if no features were set.
      contrast_pair = nil if set_feature_list.empty?
      changed = !set_feature_list.empty?
      test_result = @grammar_test_class.new(output_list, grammar)
      ContrastPairStep.new(test_result, changed, contrast_pair)
    end
  end
end
