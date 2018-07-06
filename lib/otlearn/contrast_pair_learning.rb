# Author: Bruce Tesar

require_relative 'contrast_pair'
require_relative 'uf_learning'
require_relative 'grammar_test'

module OTLearn

  # Instantiates contrast pair learning.
  # Any results of learning are realized as side effect changes to the grammar.
  class ContrastPairLearning

    # Constructs a contrast pair learning object, storing the parameters, and
    # automatically runs contrast pair learning.
    # * +winner_list+ - the winners considered to form contrast pairs
    # * +grammar+ - the current grammar (learning may alter it).
    # * +learning_module+ - the module containing several methods used for
    #   learning: #generate_contrast_pair, #set_uf_values, and
    #   #new_rank_info_from_feature.
    # * +grammar_test_class+ - the class of the object used to test
    #   the grammar. Used for testing (dependency injection).
    #
    # :call-seq:
    #   ContrastPairLearning.new(winner_list, grammar) -> obj
    #   ContrastPairLearning.new(winner_list, grammar, learning_module: module, grammar_test_class: class) -> obj
    def initialize(winner_list, grammar,
        learning_module: OTLearn, grammar_test_class: OTLearn::GrammarTest)
      @outputs = winner_list.map{|win| win.output}
      @grammar = grammar
      @learning_module = learning_module
      @grammar_test_class = grammar_test_class
      @contrast_pair = nil
      # Test the words to see which ones currently fail
      @winner_list = @outputs.map{|out| @grammar.system.parse_output(out, @grammar.lexicon)}
      @prior_result = @grammar_test_class.new(@winner_list, @grammar)
      run_contrast_pair_learning
      @test_result = @grammar_test_class.new(@winner_list, @grammar, "Contrast Pair Learning")
    end
    
    # Returns the contrast pair found by contrast pair learning. If no
    # pair was found, it returns nil.
    def contrast_pair
      @contrast_pair
    end
    
    # Returns true if contrast pair learning changed the grammar
    # (i.e., it learned anything). Returns false otherwise.
    def changed?
      return (not @contrast_pair.nil?)
    end
    
    # Returns the results of a grammar test after the completion of
    # contrast pair learning.
    def test_result
      @test_result
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
      # Create an external iterator which calls generate_contrast_pair()
      # to generate contrast pairs.
      cp_gen = Enumerator.new do |result|
        @learning_module.generate_contrast_pair(result, @winner_list,
          @grammar, @prior_result)
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
          @learning_module.new_rank_info_from_feature(@grammar, @winner_list,
            set_f)
        end
        # If an underlying feature was set, return the contrast pair.
        # Otherwise, keep processing contrast pairs.
        unless set_feature_list.empty? then
          @contrast_pair = contrast_pair
          return contrast_pair
        end
      end
      # No contrast pairs were able to set any features; return nil.
      # NOTE: loop silently rescues StopIteration, so if cp_gen runs out
      #       of contrast pairs, loop simply terminates, and execution
      #       continues below it.
      return nil
    end
    protected :run_contrast_pair_learning

  end # class ContrastPairLearning
end # module OTLearn
