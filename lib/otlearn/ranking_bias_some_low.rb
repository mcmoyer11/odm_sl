# frozen_string_literal: true

# Author: Bruce Tesar

require 'rcd'

module OTLearn
  # Implements a ranking bias
  class RankingBiasSomeLow
    def initialize(low_constraint_type)
      @low_constraint_type = low_constraint_type
    end

    def low_constraint_type?(con)
      @low_constraint_type.member?(con)
    end

    def active?(con, ercs)
      ercs.any? { |erc| erc.w?(con) }
    end

    def choose_cons_to_rank(rankable, rcd)
      low, high = rankable.partition { |con| low_constraint_type?(con) }
      # if any high kind are rankable, return all of them
      return high unless high.empty?

      low_active = low.find_all { |con| active?(con, rcd.unex_ercs) }
      # if no low kind are active, they can't free anything up, so
      # return all of the low kind.
      return low if low_active.empty?

      # return the low kind constraint that frees up the most high kind
      max_freed_high(low_active, rcd.unranked, rcd.unex_ercs)
    end

    def max_freed_high(low_active, unranked, unex_ercs)
      # Create a list of ordered pairs each of form [constrant, num_freed]
      freed_high = low_active.map do |con|
        [con, count_freed_high(con, unranked, unex_ercs)]
      end
      # find the pair with the highest num_freed
      best_pair = freed_high.max { |a, b| a[1] <=> b[1] }
      # If none of the active constraints frees any high kind, return all of
      # the low active constraints.
      return low_active if (best_pair[1]).zero?

      [best_pair[0]] # return a list with the constraint of the best pair
    end

    def count_freed_high(target_con, unranked_p, unex_ercs_p)
      stratum = [target_con]
      unex_ercs = unex_ercs_p
      ex_ercs = []
      unranked = unranked_p
      ranked = []
      total_freed_high = 0
      begin
        ranked, unranked = Rcd.rank_next_stratum(stratum, ranked, unranked)
        ex_ercs, unex_ercs =
          Rcd.move_newly_explained_ercs(stratum, ex_ercs, unex_ercs)
        rankable = unranked.find_all { |con| Rcd.rankable?(con, unex_ercs) }
        stratum = rankable.find_all { |con| !low_constraint_type?(con) }
        total_freed_high += stratum.size
      end until stratum.empty?
      total_freed_high
    end
  end
end
