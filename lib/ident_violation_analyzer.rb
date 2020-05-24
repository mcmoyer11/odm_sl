# frozen_string_literal: true

# Author: Bruce Tesar

# Checks a competition for candidates with identical constraint violation
# profiles. If any are found, it groups together candidates with identical
# violation profiles.
#
# Objects of this class delegate the method #each to the internal partition
# itself, and mixes in Enumerable.
class IdentViolationAnalyzer
  # The methods of Enumerable apply to the partition itself.
  include Enumerable

  # Creates a partition of the candidates of +competition+ by constraint
  # violation profile.
  #
  # :call-seq:
  #   IdentViolationAnalyzer.new(competition) -> analyzer
  def initialize(competition)
    @competition = competition
    @ident_viol_candidates = false # until proven otherwise
    @partition = partition_by_viols
  end

  # Delegates calls to #each to the partition, which implements #each.
  # Permits the methods of Enumerable to be used on the partition.
  def each(*args, &block)
    @partition.each(*args, &block)
  end

  # Returns true if the competition contains at least one pair of candidates
  # with identical violation profiles; returns false otherwise.
  def ident_viol_candidates?
    @ident_viol_candidates
  end

  # Returns a list of parts, where each part is a list of more than one
  # candidate with identical violation profiles. Candidates with unique
  # violation profiles do not appear anywhere in the returned list.
  def duplicate_viol_candidates
    @partition.find_all { |part| part.size > 1 }
  end

  # Partitions the candidates by constraint violation profiles.
  # The partition is an array of arrays, the latter are the parts.
  # Each part contains candidates with identical violation profiles.
  def partition_by_viols
    partition = []
    @competition.each do |cand|
      match = partition.find_index { |part| part[0].ident_viols? cand }
      add_to_partition(cand, match, partition)
    end
    partition
  end
  private :partition_by_viols

  # Adds +cand+ to +partition+ based on +match+. If +match+ is not nil,
  # add +cand+ to the part at index +match+, otherwise add as a new part.
  def add_to_partition(cand, match, partition)
    if !match.nil?
      partition[match] << cand
      @ident_viol_candidates = true
    else
      partition << [cand]
    end
  end
  private :add_to_partition
end
