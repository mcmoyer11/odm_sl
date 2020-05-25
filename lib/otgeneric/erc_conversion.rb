# Author: Bruce Tesar

require 'constraint'
require 'erc_list'

# Contains classes for a linguistic system read in entirely from a table-like
# file, where all constraint names and candidate contents are listed out as
# strings.
module OTGeneric
  
  # Contains various module methods for converting between "array of string"
  # representations of ERC lists, and ErcList / Erc object representations.
  module Erc_conversion
    
    # Takes an array of column headers +headers+, and an array of arrays
    # +data+, and returns an equivalent ErcList of ERCs.
    def Erc_conversion.arrays_to_erc_list(headers, data)
      constraints = []
      con_headers = headers[1..-1]
      con_headers.each_with_index do |head, i| # all but first column
        con = Constraint.new(head, i, Constraint::MARK)
        constraints << con
      end
      erc_list = ErcList.new(constraint_list: constraints)
      #
      data.each do |row|
        erc = Erc.new(constraints)
        erc.label = row[0]
        evals = row[1..-1] # all but first column
        evals.each_with_index do |eval, i|
          if eval == 'W' then
            erc.set_w(constraints[i])
          elsif eval == 'L' then
            erc.set_l(constraints[i])
          end
        end
        erc_list.add(erc)
      end
      return erc_list
    end
  end
end
