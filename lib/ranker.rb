# frozen_string_literal: true

# Author: Bruce Tesar

require 'rcd_runner'

# Objects of class Ranker respond to #get_hierarchy(ercs) by returning
# a constraint hierarchy consistent with +ercs+.
class Ranker
  # Returns a ranker object which will construct a constraint hierarchy
  # consistent with a list of ercs, in accordance with the ranking
  # bias embedded in the +rcd_runner+. By default, the runner has a bias
  # to rank all constraints as high as possible.
  # :call-seq:
  #   Ranker.new -> ranker
  #   Ranker.new(rcd_runner) -> ranker
  def initialize(rcd_runner = RcdRunner.new)
    @rcd_runner = rcd_runner
  end

  # Returns a constraint hierarchy consistent with +ercs+, subject to
  # the ranking bias of the embedded RCD runner.
  # TODO: raise an exception if the ercs are inconsistent.
  def get_hierarchy(ercs)
    rcd = @rcd_runner.run_rcd(ercs)
    rcd.hierarchy
  end
end
