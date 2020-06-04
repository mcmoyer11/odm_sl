# frozen_string_literal: true

# Author: Bruce Tesar

require 'ranking_bias_all_high'
require 'rcd'

class RcdRunner
  def initialize(chooser = RankingBiasAllHigh.new, rcd_class: Rcd)
    @chooser = chooser
    @rcd_class = rcd_class
  end

  def run_rcd(erc_list)
    @rcd_class.new(erc_list, constraint_chooser: @chooser)
  end
end
