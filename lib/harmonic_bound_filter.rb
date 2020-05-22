# frozen_string_literal: true

# Author: Bruce Tesar

require_relative '../lib/erc_list'

# Provides a method for filtering out harmonically bound candidates.
class HarmonicBoundFilter
  # Returns a new HarmonicBoundFilter.
  #
  # :call-seq:
  #   HarmonicBoundFilter.new() -> HarmonicBoundFilter
  def initialize(erc_list_class: ErcList)
    @erc_list_class = erc_list_class
  end

  # Returns an array containing those candidates of +competition+ that
  # are not collectively harmonically bound.
  def remove_collectively_bound(competition)
    contenders = []
    competition.each do |target_cand|
      # Ercs with target as the winner, others as the loser
      erc_list = @erc_list_class.new_from_competition(target_cand, competition)
      contenders << target_cand if erc_list.consistent?
    end
    contenders
  end
end
