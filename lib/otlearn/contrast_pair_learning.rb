# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/otlearn'
require 'otlearn/contrast_pair'
require 'otlearn/uf_learning'
require 'otlearn/paradigm_erc_learning'
require 'otlearn/grammar_test'

module OTLearn
  # Instantiates contrast pair learning.
  # Any results of learning are realized as side effect changes to the grammar.
  class ContrastPairLearning
    # The type of learning step
    attr_accessor :step_type

    # The paradigmatic ERC learner. Default: ParadigmErcLearning.new
    attr_accessor :para_erc_learner

    # The contrast pair found by contrast pair learning.
    # nil if no pair was found.
    attr_reader :contrast_pair

    # Grammar test result after the completion of contrast pair learning.
    attr_reader :test_result

    # Constructs a contrast pair learning object, storing the parameters, and
    # automatically runs contrast pair learning.
    # * +output_list+ - the winners considered to form contrast pairs
    # * +grammar+ - the current grammar (learning may alter it).
    #--
    # learning_module and grammar_test_class are dependency injections used
    # for testing.
    # * +learning_module+ - the module containing #generate_contrast_pair
    #   and #set_uf_values.
    # * +grammar_test_class+ - the class of the object used to test
    #   the grammar. Used for testing (dependency injection).
    #++
    #
    # :call-seq:
    #   ContrastPairLearning.new(output_list, grammar) -> obj
    def initialize(output_list, grammar, para_erc_learner: ParadigmErcLearning.new,
                   grammar_test_class: OTLearn::GrammarTest,
                   learning_module: OTLearn)
      @output_list = output_list
      @grammar = grammar
      @learning_module = learning_module
      @grammar_test_class = grammar_test_class
      @para_erc_learner = para_erc_learner
      @contrast_pair = nil
      @step_type = CONTRAST_PAIR
      run_contrast_pair_learning
      @test_result = @grammar_test_class.new(@output_list, @grammar)
    end

    # Returns true if contrast pair learning changed the grammar
    # (i.e., it learned anything). Returns false otherwise.
    def changed?
      !@contrast_pair.nil?
    end

    # Returns true if all words are correctly processed by the grammar;
    # returns false otherwise.
    def all_correct?
      @test_result.all_correct?
    end

    # Select a contrast pair, and process it, attempting to set underlying
    # features. If any features are set, check for any newly available
    # ranking information.
    #
    # This method returns the first contrast pair that was able to set
    # at least one underlying feature. If none of the constructed
    # contrast pairs is able to set any features, nil is returned.
    def run_contrast_pair_learning
      # Test the words to see which ones currently fail
      winner_list = @output_list.map do |out|
        @grammar.parse_output(out)
      end
      prior_result = @grammar_test_class.new(@output_list, @grammar)
      # Create an external iterator which calls generate_contrast_pair()
      # to generate contrast pairs.
      cp_gen = Enumerator.new do |result|
        @learning_module.generate_contrast_pair(result, winner_list,
                                                @grammar, prior_result)
      end
      # Process contrast pairs until one is found that sets an underlying
      # feature, or until all contrast pairs have been processed.
      loop do
        contrast_pair = cp_gen.next
        # Process the contrast pair, and return a list of any features
        # that were newly set during the processing.
        set_feature_list = @learning_module.set_uf_values(contrast_pair,
                                                          @grammar)
        # For each newly set feature, see if any new ranking information
        # is now available.
        set_feature_list.each do |set_f|
          @para_erc_learner.run(set_f, @grammar, @output_list)
        end
        # If an underlying feature was set, return the contrast pair.
        # Otherwise, keep processing contrast pairs.
        unless set_feature_list.empty?
          @contrast_pair = contrast_pair
          return contrast_pair
        end
      end
      # No contrast pairs were able to set any features; return nil.
      # NOTE: loop silently rescues StopIteration, so if cp_gen runs out
      #       of contrast pairs, loop simply terminates, and execution
      #       continues below it.
      nil
    end
    protected :run_contrast_pair_learning
  end
end
