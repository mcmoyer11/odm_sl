# frozen_string_literal: true

# Author: Bruce Tesar

require 'rcd'

module OTLearn
  # Implements a ranking bias in which a specified kind of constraint
  # is ranked as low as possible. A ranking bias object should be
  # invoked during learning with the method #choose_cons_to_rank.
  # Execution of this method will invoke several class methods of
  # the class Rcd, and an rcd object is one of the parameters to
  # the method.
  class RankingBiasSomeLow
    # Returns a new ranking bias object.
    # The parameter +low_constraint_type+ should respond to the method
    # #member(constraint), returning true of the constraint is a member
    # of the class of constraints to be low-ranked.
    # :call-seq:
    #   RankingBiasSomeLow.new(low_type) -> bias
    def initialize(low_constraint_type)
      @low_constraint_type = low_constraint_type
    end

    # Returns true of +con+ is a constraint that should be low-ranked.
    def low_constraint_type?(con)
      @low_constraint_type.member?(con)
    end

    # Returns true if the +con+ is active with respect to +ercs+, meaning
    # it prefers the winner in at least one of the ERCs.
    def active?(con, ercs)
      ercs.any? { |erc| erc.w?(con) }
    end

    # Returns an array of constraints from among those in +rankable+
    # that are to be ranked next according to the ranking bias.
    def choose_cons_to_rank(rankable, rcd)
      # Get the current unranked constraints and unexplained ercs
      unranked = rcd.unranked
      unex_ercs = rcd.unex_ercs
      # partition the constraints into low and high kind lists
      low, high = rankable.partition { |con| low_constraint_type?(con) }
      # if any high kind are rankable, return all of them
      return high unless high.empty?

      low_active = low.find_all { |con| active?(con, unex_ercs) }
      # if no low kind are active, they can't free anything up, so
      # return all of the low kind.
      return low if low_active.empty?

      # return the low kind constraint that frees up the most high kind
      max_freed_high(low_active, unranked, unex_ercs)
    end

    # Chooses, from among the active low-kind constraints, the one
    # that frees up the most high-kind constraints, and returns
    # an array containing that constraint.
    # If none of the constraints frees any high-kind constraints, then
    # an array of all the active low-kind constraints is returned.
    # If more than one constraint ties for the most high-kind constraints
    # freed, only one of them is returned.
    # :call-seq:
    #   max_freed_high(low_active, unranked, unex_ercs) -> arr
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
    protected :max_freed_high

    # Counts the number of high-kind constraints freed up by ranking
    # +target_con+ next, and returns that number.
    def count_freed_high(target_con, unranked_p, unex_ercs_p)
      stratum = [target_con]
      unex_ercs = unex_ercs_p
      ex_ercs = []
      unranked = unranked_p
      ranked = []
      total_freed_high = 0
      # repeat RCD-type passes until no rankable high-kind constraints remain.
      loop do
        ranked, unranked = Rcd.rank_next_stratum(stratum, ranked, unranked)
        ex_ercs, unex_ercs =
          Rcd.move_newly_explained_ercs(stratum, ex_ercs, unex_ercs)
        rankable = unranked.find_all { |con| Rcd.rankable?(con, unex_ercs) }
        stratum = rankable.find_all { |con| !low_constraint_type?(con) }
        total_freed_high += stratum.size
        break if stratum.empty?
      end
      total_freed_high
    end
    protected :count_freed_high
  end
end
