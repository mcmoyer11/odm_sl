# frozen_string_literal: true

# Author: Bruce Tesar

require 'ranking_bias_all_high'
require 'rcd'

# An RcdRunner enables the running of an instance of RCD with
# a pre-specified ranking bias, provided by the +chooser+ parameter.
# An instance of RCD is launched by calling the method #run_rcd
# on the runner.
class RcdRunner
  # Creates a new runner. The ranking bias can be provided by
  # the +chooser+ parameter, with a default value of
  # RankingBiasAllHigh.new.
  #--
  # Named parameter +rcd_class+ is a dependency injection used for testing.
  #++
  # :call-seq:
  #   RcdRunner.new -> runner
  #   RcdRunner.new(chooser) -> runner
  def initialize(chooser = RankingBiasAllHigh.new, rcd_class: Rcd)
    @chooser = chooser
    @rcd_class = rcd_class
  end

  # Runs RCD on +erc_list+. Returns a new instance of class Rcd
  # containing the results.
  # :call-seq:
  #   runner.run_rcd(erc_list) -> Rcd
  def run_rcd(erc_list)
    @rcd_class.new(erc_list, constraint_chooser: @chooser)
  end
end
