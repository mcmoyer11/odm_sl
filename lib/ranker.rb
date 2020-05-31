# frozen_string_literal: true

# Author: Bruce Tesar

require 'rcd'

# Takes a class +rcd_class+ for creating and representing RCD-style
# executions, and returns an object that can take a list of ercs
# and return a consistent constraint hierarchy in one call.
class Ranker
  # Returns a ranker object which will construct a constraint hierarchy
  # consistent with a list of ercs, in accordance with the ranking
  # bias embedded in the +rcd_class+. The default value of the +rcd_class+
  # is Rcd, which has a bias to rank all constraints as high as possible.
  # :call-seq:
  # Ranker.new(rcd_class) -> ranker
  def initialize(rcd_class = Rcd)
    @rcd_class = rcd_class
  end

  # Returns a constraint hierarchy consistent with +ercs+, subject to
  # the ranking bias of the embedded rcd_class.
  def get_hierarchy(ercs)
    rcd = @rcd_class.new(ercs)
    rcd.hierarchy
  end
end
