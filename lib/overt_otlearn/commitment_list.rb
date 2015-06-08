# Author: Crystal Akers
#

require_relative '../hypothesis'
require_relative '../otlearn'
require_relative 'data_manip'
require_relative '../sf/sf_output'

module Overt_OTLearn

# Commitments are arrays containing pairs of overt form and committed output,
# each pair a size 2 array with the first element an overt form and the second
# element a structural interpretation of the overt form.

  class Commitment_List < Array

    # Returns an empty Commitment list
    def initialize
    end

    # Returns true if the string representation of _form_ matches that of either
    # member of the commitment (overt form or structural interpretation);
    # it returns false otherwise.
    def forms_match?(form, commit_pair)
      return true if commit_pair.any? {|committed_form| committed_form.to_s == form.to_s}
      return false
    end

    # Returns the commitment pair whose overt form or committed output interpretation
    # matches _form_; it returns nil if there's no such pair.
    def existing_commitment_pair(form)
      self.each { |commit_pair| return commit_pair if self.forms_match?(form, commit_pair) }
      return nil
    end

    # Adds to a new commitment pair with the structural interpretation provided
    # by _output_. Returns the new pair.
    def add_commitment_pair(output)
      # _output_ must not match an existing commitment pair
      raise "Existing commitment for output: #{output.overt.to_s}, #{output.to_s}" if
        self.existing_commitment_pair(output)
      # The overt form of _output_ must not match an existing commitment pair
      overt = output.overt
      raise "Existing commitment for overt form: #{output.overt.to_s}, #{output.to_s}" if
        self.existing_commitment_pair(overt)
      commitment_pair = [overt, output.dup]
      self << commitment_pair
      return commitment_pair
    end

    #Returns a copy of the commitment pair
    def dup
      super
    end

    def to_s
      out_str = ""
      self.each do |commit_pair|
        out_str << "["
        out_str << commit_pair[0].join
        out_str << ", "
        out_str << commit_pair[1].join
        out_str << "]"
        out_str << "\n"
      end
      return out_str
    end

  end # class Commitment
end # module Overt_OTLearn