# Author: Crystal Akers

require_relative '../sf/sf_word'
require_relative '../sf/system'
require 'set'

module Overt_OTLearn
  class Label_set < Set

    # Create a new, blank label set. The label set is composed of individual label hashes.
    def initialize
      super
    end

    # Creates a new label and adds it to the label set. Each label consists of a hash.
    # The first hash key is the string representation of _overt_form_ and is given the
    # value of _letter_. The following keys are for structural interpretations,
    # with one key for each string representation of a structural interpretation of
    #  _overt_form_, and number values for each key. Returns the label.
    # Label:  [overt_form => letter, output1 => 1, output2 => 2, ...]
    def create_new_label_hash(overt_form, lang_hyp, letter)
      label= Hash.new
      overt = overt_form.dup
      # Add the string rep. of the overt form and letter value to the hash
      label[overt.to_s] = letter.dup
      # Create keys and values for string reps. of structural interpretations
      num = "0"
      interpretations = lang_hyp.system.get_interpretations(overt_form, lang_hyp.grammar)
      interpretations.each do |word|
        output = word.output.dup
        num = num.succ
        label[output.to_s] = num
      end
      # Add the new label to the label set
      self << label
      return label
    end

    # Updates the label of _lang_hyp_ with the label associated with _overt_form_.
    # Unless some label hash already contains _overt_form_, a new one is created.
    def update_lang_hyp_label(overt, lang_hyp, letter)
      overt_hash = find_label_hash(overt)
      if overt_hash ==  nil then
        overt_hash = create_new_label_hash(overt, lang_hyp, letter)
        letter = letter.succ
      end
      # Break if the _lang_hyp_ label already includes the label for this overt form
      unless lang_hyp.lang_hyp_label.empty? then
        return letter if lang_hyp.lang_hyp_label.include?(overt_hash[overt.to_s])
      end
      # Get the output commitment for this overt form in _lang_hyp_
      output = lang_hyp.commitments.existing_commitment_pair(overt)[1]
      raise "Cannot create new label without a committed output" if output == nil
      # Append the values of the keys matching _overt_ and _output_ in string representation.
      lang_hyp.lang_hyp_label << overt_hash[overt.to_s] << overt_hash[output.to_s]
      # Return the letter to be used for the next new label hash
      return letter
    end


    # Searches through the label set to find the label containing the given form _f_.
    # Returns that label.
    def find_label_hash(f)
      form = f.to_s
      matching_hashes = self.find_all {|label| label.any? {|el| el.include?(form)}}
      if matching_hashes.size >1 then
        raise "Error - more than one label hash exists for the form #{f.to_s}"
      else
        return matching_hashes[0]
      end
      return nil
    end

  end # class Label_set
end #module Overt_OTLearn