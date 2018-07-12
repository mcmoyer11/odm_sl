# Author: Bruce Tesar

require 'sheet'

module OTLearn
  
  # A 2-dimensional sheet representation of a Fewest Set Features learning
  # step.
  class FewestSetFeaturesImage
    
    # Constructs a new image for the provided FSF learning step.
    # * +step+ - the Fewest Set Features learning step object.
    #
    # :call-seq:
    #   FewestSetFeaturesImage.new(fewest_set_features_step) -> img
    def initialize(step)
      @step = step
      @sheet = Sheet.new
      construct_image
    end

    # Delegate all method calls not explicitly defined here to the sheet object.
    def method_missing(name, *args)
      @sheet.send(name, *args)
    end
    protected :method_missing
    
    # Constructs the FSF sheet image
    def construct_image
      @sheet[1,1] = "Fewest Set Features"
      # indicate if the grammar was changed
      @sheet[2,1] = "Grammar Changed: #{@step.changed?.to_s.upcase}"
      add_failed_winner_info
    end
    protected :construct_image
    
    # Adds info about the failed winner to the sheet
    def add_failed_winner_info
      failed_winner = @step.failed_winner
      subsheet = Sheet.new
      subsheet[1,2] = "Failed Winner"
      subsheet[1,3] = failed_winner.morphword.to_s
      subsheet[1,4] = failed_winner.input.to_s
      subsheet[1,5] = failed_winner.output.to_s
      @sheet.append(subsheet)
    end
    protected :add_failed_winner_info
  end # class FewestSetFeaturesImage
end # module OTLearn
