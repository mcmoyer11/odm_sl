# Author: Bruce Tesar
#

module OTLearn
  class ContrastPairLearning
    
    def initialize(winner_list, grammar, prior_result)
      @winner_list = winner_list
      @grammar = grammar
      @prior_result = prior_result
      # injection dependency defaults
      @otlearn_module = OTLearn
    end
    
    # Resets the module providing the namespace for various learning methods.
    # Used in testing (dependency injection).
    def otlearn_module=(mod)
      @otlearn_module = mod
    end

    # Select a contrast pair, and process it, attempting to set underlying
    # features. If any features are set, check for any newly available
    # ranking information.
    # 
    # This method returns the first contrast pair that was able to set
    # at least one underlying feature. If none of the constructed
    # contrast pairs is able to set any features, nil is returned.
    def run
      # Create an external iterator which calls generate_contrast_pair()
      # to generate contrast pairs.
      cp_gen = Enumerator.new do |result|
        @otlearn_module.generate_contrast_pair(result, @winner_list, @grammar, @prior_result)
      end
      # Process contrast pairs until one is found that sets an underlying
      # feature, or until all contrast pairs have been processed.
      loop do
        contrast_pair = cp_gen.next
        # Process the contrast pair, and return a list of any features
        # that were newly set during the processing.
        set_feature_list = @otlearn_module.set_uf_values(contrast_pair, @grammar)
        # For each newly set feature, see if any new ranking information
        # is now available.
        set_feature_list.each do |set_f|
          @otlearn_module.new_rank_info_from_feature(@grammar, @winner_list, set_f)
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

  end # class ContrastPairLearning
end # module OTLearn
