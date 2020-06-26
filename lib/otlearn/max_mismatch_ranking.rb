# frozen_string_literal: true

# Author: Morgan Moyer / Bruce Tesar

require 'word'
require 'otlearn/mmr_exceptions'
require 'otlearn/erc_learning'

module OTLearn
  # MaxMismatchRanking takes a list of outputs of winners that are failing
  # Initial Word Evaluation (where the candidate created using the maximally
  # dissimilar input paired with the output is error tested),
  # but that are consistent with the grammar, in the sense that there exists
  # a ranking consistent with the grammar's support under which the winner
  # succeeds (is optimal).
  # One of the outputs is chosen, and parsed into a word where the input is
  # mismatched with the output. The learner computes the additional ranking
  # information necessary to make the winner successful, and adds that
  # information to the grammar's actual support. The change to the grammar
  # is achieved as a side effect on the grammar passed to the constructor.
  # The returned object contains the other products of the procedure.
  #
  # This class would typically be invoked when neither single form learning nor
  # contrast pairs are able to make further progress, yet learning is
  # not yet complete, suggesting that a paradigmatic subset relation is present.
  # The learner is making the inductive leap that the failed output, because
  # it is consistent, is likely an actual grammatical output, and it
  # further maximizes the number of inputs mapping to the output by mapping
  # the max mismatch input, thus enforcing greater restrictiveness.
  #
  # This assumes that all of the unset features are binary; see the
  # documentation for Word#mismatch_input_to_output!.
  class MaxMismatchRanking
    # The ERC that the algorithm has created.
    attr_reader :newly_added_wl_pairs

    # The failed winner that was used with max mismatch ranking.
    attr_reader :failed_winner

    # Initializes a new object, *and* automatically executes
    # the max mismatch ranking algorithm.
    # * +output_list+ is the list of outputs of *consistent*
    #    failed winners that are candidates for use in MMR.
    # * +grammar+ is the current grammar of the learner.
    # :call-seq:
    #   MaxMismatchRanking.new(output_list, grammar) -> mmrlearner
    def initialize(output_list, grammar,
                   erc_learner: ErcLearning.new)
      @grammar = grammar
      @output_list = output_list
      @erc_learner = erc_learner
      @newly_added_wl_pairs = []
      @failed_winner = nil
      @changed = false
      # automatically execute MMR
      run_max_mismatch_learning
    end

    # Returns true if MaxMismatchRanking has found a consistent WL pair
    def changed?
      @changed
    end

    # Executes the Max Mismatch Ranking algorithm.
    #
    # The learner chooses a single consistent failed winner from the list.
    # For that failed winner, the learner takes the input with all
    # unset features set opposite their surface value and creates a candidate.
    # Then, MRCD is used to construct the ERCs necessary to make that
    # candidate grammatical.
    #
    # Returns True if the consistent max mismatch candidate provides
    # new ranking information. Raises an exception if it does not provide new
    # ranking information.
    def run_max_mismatch_learning
      @failed_winner = choose_failed_winner
      mrcd_result = @erc_learner.run([@failed_winner], @grammar)
      @changed = mrcd_result.any_change?
      unless @changed
        msg1 = 'A failed consistent winner'
        msg2 = 'did not provide new ranking information.'
        raise MMREx.new(@failed_winner), "#{msg1} #{msg2}"
      end
      @newly_added_wl_pairs = mrcd_result.added_pairs
      @changed
    end
    private :run_max_mismatch_learning

    # Choose, from among the consistent failed winners, the failed winner to
    # use with MMR. Returns a full word with the input initialized so that
    # set features match the lexicon and unset features mismatch the output.
    def choose_failed_winner
      chosen_output = @output_list.first
      chosen_winner = @grammar.parse_output(chosen_output)
      chosen_winner.mismatch_input_to_output!
      chosen_winner
    end
    private :choose_failed_winner
  end
end
