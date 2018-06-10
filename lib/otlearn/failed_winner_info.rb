# Author: Bruce Tesar
#

module OTLearn

  # Contains information on a failed winner for a grammar test. A failed
  # winner is a winner which is not a sole optimum with respect to
  # the evaluation hierarchy. It is either non-optimal, or ties for
  # optimality with other candidates.
  # Three kinds of information are stored:
  # * the failed winner itself
  # * a list of the optimal candidates (apart from the failed winner)
  # * a boolean flag indicating if the failed winner is optimal.
  class FailedWinnerInfo
    # Returns a failed winner information object, containing
    # the three objects passed as parameters.
    # [_failed_winner_] the failed winner candidate
    # [_alt_optima_] a list of the optimal candidates (not including _failed_winner_)
    # [winner_optimal_flag] a boolean indicating if _failed_winner_ is optimal (true) or not (false).
    def initialize(failed_winner, alt_optima, winner_optimal_flag)
      @failed_winner = failed_winner
      @alt_optima = alt_optima
      @winner_optimal_flag = winner_optimal_flag
    end
    
    # Returns the failed winner candidate.
    def failed_winner
      @failed_winner
    end
    
    # Returns a list of the optimal candidates. If the failed winner itself
    # ties for optimality it is *not* included in this list.
    def alt_optima
      @alt_optima
    end
    
    # Returns true if the failed winner is optimal (ties for optimality),
    # false otherwise.
    def winner_optimal_flag
      @winner_optimal_flag
    end
    
  end # class FailedWinnerInfo
end # module OTLearn
