# frozen_string_literal: true

# Author: Bruce Tesar

require 'otlearn/contrast_pair'
require 'otlearn/uf_learning'
require 'otlearn/grammar_test'
require 'otlearn/language_learning'
require 'compare_consistency'
require 'loser_selector'
require 'loser_selector_from_gen'

module OTLearn
  # Instantiates contrast pair learning.
  # Any results of learning are realized as side effect changes to the grammar.
  class ContrastPairLearning
    # The type of learning step
    attr_accessor :step_type

    # The contrast pair found by contrast pair learning.
    # nil if no pair was found.
    attr_reader :contrast_pair

    # Grammar test result after the completion of contrast pair learning.
    attr_reader :test_result

    # Constructs a contrast pair learning object, storing the parameters, and
    # automatically runs contrast pair learning.
    # * +output_list+ - the winners considered to form contrast pairs
    # * +grammar+ - the current grammar (learning may alter it).
    # * +loser_selector+ - object used for loser selection; defaults to
    #   a loser selector using CompareConsistency.
    #--
    # learning_module and grammar_test_class are dependency injections used
    # for testing.
    # * +learning_module+ - the module containing several methods used for
    #   learning: #generate_contrast_pair, #set_uf_values, and
    #   #new_rank_info_from_feature.
    # * +grammar_test_class+ - the class of the object used to test
    #   the grammar. Used for testing (dependency injection).
    #++
    #
    # :call-seq:
    #   ContrastPairLearning.new(output_list, grammar) -> obj
    #   ContrastPairLearning.new(output_list, grammar, loser_selector: selector) -> obj
    def initialize(output_list, grammar, loser_selector: nil,
                   grammar_test_class: OTLearn::GrammarTest,
                   learning_module: OTLearn)
      @output_list = output_list
      @grammar = grammar
      @learning_module = learning_module
      @grammar_test_class = grammar_test_class
      @contrast_pair = nil
      @loser_selector = loser_selector
      # Cannot put the default in the parameter list because of the call
      # to grammar.system.
      if @loser_selector.nil?
        basic_selector = LoserSelector.new(CompareConsistency.new)
        @loser_selector = LoserSelectorFromGen.new(grammar.system,
                                                   basic_selector)
      end
      @step_type = LanguageLearning::CONTRAST_PAIR
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
          @learning_module \
            .new_rank_info_from_feature(@grammar, winner_list, set_f,
                                        loser_selector: @loser_selector)
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
