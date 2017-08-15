# Author: Bruce Tesar
#
# TODO: change RcdBiasLow so that the ranking bias is supplied as
# an object to the constructor (dependency injection).
 
require_relative '../rcd'

module OTLearn
  
  # RcdBiasLow is an "abstract" subclass of Rcd that defines a variant
  # of Rcd with a bias towards ranking some constraints as low as possible
  # (by default, Rcd ranks all constraints as high as possible).
  # To fully implement such an algorithm, a subclass is required which
  # implements the method low_constraint_type?(con), which returns true
  # for any constraint of the class to be biased low in the ranking.
  # 
  # Given a comparative tableau, RcdBiasLow.new() tries to find the
  # constraint hierarchy consistent with the data (if one exists), that has
  # the low-bias constraints ranked as low as possible, and the other (high_bias)
  # constraints ranked as high as possible.
  # 
  # This is related to Biased Constraint Demotion, or BCD, which defines
  # the low-bias constraints to be the faithfulness constraints. However, it
  # does not fully pursue minimal f-gangs; if no single faithfulness constraint
  # frees up any markedness constraints, then all active faithfulness
  # constraints are ranked. This is to keep the computational complexity down.
  # Reference: Prince & Tesar.
  class RcdBiasLow < Rcd
    
    # Accepts a comparative tableau +ct+ and an optional +label+.
    # The default label value is "RcdBiasLow".
    # Returns an Rcd object. The constraint bias must be provided by
    # a concrete subclass by overriding the #low_constraint_type? method.
    def initialize(ct, label: 'RcdBiasLow')
      super
    end
    
    # This overrides the method of Rcd, implementing a "low as possible"
    # ranking bias for constraints of type low_constraint_type?().
    def choose_cons_to_rank(rankable)
      # If any high-bias constraints are rankable, only rank them.
      low_rankable, high_rankable = rankable.partition{|con| low_constraint_type?(con)}
      return high_rankable unless high_rankable.empty?
      # If any low-bias constraints are active, only rank them.
      low_active = low_rankable.find_all{|con| active?(con)}
      unless low_active.empty? then
        # find the low-bias constraint that frees the most high-bias constraints
        low_active_counts = low_active.map{|con| [con,count_freed_high(con)]}
        best_pair = low_active_counts.max{|a,b| a[1]<=>b[1]}
        if best_pair[1]==0 then chosen_list = low_active
        else chosen_list = [best_pair[0]]
        end
        return chosen_list
      end
      # Otherwise, return all the low-bias constraints
      return low_rankable
    end
    
    # Returns the number of high_bias constraints that would be freed up
    # if the given low-bias constraint were ranked next.
    def count_freed_high(low_con)
      # Set up data structures as if low_con were ranked next.
      # Local variables and duplicates of class instance variables are used,
      # so that the actual state of hierarchy construction is undisturbed.
      unexplained = self.unex_ercs.dup
      stratum = [low_con]
      unranked = self.unranked - stratum
      total_high_con_count = 0
      # Remove ercs explained by low_con, and see if any high-bias
      # constraints are freed up.
      explained, unexplained = unexplained.partition{|e| explained?(e, stratum)}
      rankable, unranked = unranked.partition{|con| rankable?(con, unexplained)}
      low_rankable, high_rankable = rankable.partition{|con| low_constraint_type?(con)}
      total_high_con_count += high_rankable.size # add to the count of the high-bias cascade.
      # If some high-bias constraints were freed up, see if, once those
      # constraints are ranked, more high-bias constraints are freed up.
      # Continue to the end of the high-bias cascade (no more high-bias
      # constraints can be ranked), keeping count of the total number of
      # constraints in the cascade.
      until high_rankable.empty?
        stratum = high_rankable # "rank" only the high-bias constraints
        unranked.concat(rankable - stratum)
        explained, unexplained = unexplained.partition{|e| explained?(e, stratum)}
        # See if more high-bias constraints have been freed up
        rankable, unranked = unranked.partition{|con| rankable?(con, unexplained)}
        low_rankable, high_rankable = rankable.partition{|con| low_constraint_type?(con)}
        total_high_con_count += high_rankable.size
      end
      return total_high_con_count
    end
    
    # Returns true if the given constraint is active, that is, if it prefers
    # the winner for at least one of the as-yet-unexplained ercs.
    def active?(con)
      self.unex_ercs.any? { |e| e.w?(con) }
    end
    
  end # class RcdBiasLow

  # RcdFaithLow is a subclass of Rcd that has a "markedness high, faithfulness
  # low" ranking bias. Given a comparative tableau, it tries to find the
  # constraint hierarchy consistent with the data (if one exists), that has
  # the faithfulness constraints ranked as low as possible.
  # 
  # This is related to Biased Constraint Demotion, or BCD, but does not
  # fully pursue minimal gangs of low-bias constraints; if no single
  # faithfulness constraint frees up any markedness constraints, then all
  # active faithfulness constraints are ranked. This is to keep the
  # computational complexity down.
  # Reference: Prince & Tesar.
  class RcdFaithLow < RcdBiasLow
    def low_constraint_type?(con)
      con.faithfulness?
    end
  end # class RcdFaithLow

  # RcdMarkLow is a subclass of Rcd that has a "faithfulness high, markedness
  # low" ranking bias. Given a comparative tableau, it tries to find the
  # constraint hierarchy consistent with the data (if one exists), that has
  # the markedness constraints ranked as low as possible.
  # 
  # This is related to Biased Constraint Demotion, or BCD, but does not
  # fully pursue minimal gangs of low-bias constraints; if no single markedness
  # constraint frees up any faithfulness constraints, then all active markedness
  # constraints are ranked. This is to keep the computational complexity down.
  # Reference: Prince & Tesar.
  class RcdMarkLow < RcdBiasLow
    def low_constraint_type?(con)
      con.markedness?
    end
  end # class RcdMarkLow

end # module OTLearn
