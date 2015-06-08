# Author: Bruce Tesar
#

require_relative 'uf_learning'
require_relative 'data_manip'

module OTLearn

  # A GrammarTest object holds the results of the evaluation of a set
  # of winners with respect to a hypothesis. The tests are initiated by
  # creating a GrammarTest; the constructor takes a list of winners and
  # a hypothesis as parameters.
  #
  # Each winner is a Word, possibly with unset features in the input.
  class GrammarTest

    # Returns a new GrammarTest, for the provided _winners_, and with
    # respect to the provided _hypothesis_.
    def initialize(winners, hypothesis, label="NoLabel")
      @label = label
      # Dup the hypothesis, so it can be frozen.
      @hypothesis = hypothesis.dup
      # Dup the winners, and then adjust their UI correspondence relns
      # to refer to the dup hypothesis.
      @winners = winners.map{|win| win.dup}
      @winners.each{|win| win.sync_with_hypothesis!(@hypothesis)}
      # Reset the ranking, using "faithfulness low".
      @hypothesis.update_grammar {|ercs| RcdFaithLow.new(ercs)}
      # Initialize lists for failed and successful winners
      @failed_winner_info_list = []
      @success_winners = []
      check_all
      # Freeze the test results, so they cannot be accidentally altered later.
      @hypothesis.freeze
      @winners.each {|win| win.freeze}
      @winners.freeze
      @failed_winner_info_list.each {|info| info.freeze}
      @failed_winner_info_list.freeze
      @success_winners.each {|sw| sw.freeze}
      @success_winners.freeze
    end

    # Returns the label assigned by the constructor.
    def label()
      @label
    end

    # Returns the grammar hypothesis used in this test.
    # NOTE: returned object is frozen, and cannot be altered.
    # Create a duplicate to alter it.
    def hypothesis()
      @hypothesis
    end

    # Returns true if all winners in the winner list are the sole optima
    # for inputs with all unset features set to mismatch the surface of
    # the winner.
    def all_correct?
      @failed_winner_info_list.empty?
    end

    # Returns a list of the winners that are *not* the sole optima
    # for inputs with all unset features set to mismatch the surface of
    # the winner.
    def failed_winners()
      @failed_winner_info_list.map{|fw_info| fw_info.failed_winner}
    end

    # Returns a list of failed winner information objects
    # (class FailedWinnerInfo), one for each failed winner.
    def failed_winner_info_list()
      @failed_winner_info_list
    end

    # Returns a list of the winners that succeeded (are sole optima for
    # inputs with all unset features set to mismatch their surface correspondents.
    def success_winners()
      @success_winners
    end

    # Checks each of the winners to see if they are the sole optimum for
    # their respective inputs. The full input for a winner is constructed
    # by using, for each unset underlying feature, a value that is the
    # *opposite* of the value of the feature for the output correspondent.
    # In other words, adopt values for unset features to maximize the
    # set of disparities. If the candidate with the maximum disparity set
    # is the sole optimum, then output-driven map structure ensures that
    # every other possible candidate for that winner output is also
    # optimal, because it will have a subset of the possible disparities.
    # Thus, none of the remaining unset features matters.
    #
    # If some of the features are suprabinary, than all combinations of
    # non-output-matching values for the unset features are tried.
    #
    # Each winner that does not form a sole optimal candidate with a
    # maximally distinct input is added to the failed winner list,
    # accessible by #failed_winners.
    def check_all
      @winners.each do |word|
        OTLearn::mismatches_input_to_output(word) do |mismatched_word|
          alt_optima, winner_optimal = check_winner(mismatched_word)
          unless winner_optimal && alt_optima.empty? then
            @failed_winner_info_list <<
              FailedWinnerInfo.new(mismatched_word,alt_optima,winner_optimal)
          else
            @success_winners << mismatched_word
          end
        end
      end
    end

    # Checks _winner_ to see if it is an optimal candidate, and if it is
    # the only optimal candidate. Returns a two-element array, with the
    # first element a list of optimal candidates with an output distinct
    # from _winner_, and the second element a boolean: true if _winner_
    # is an optimum, false otherwise.
    #
    # Optimality is assessed relative to the current hypothesis (the one
    # provided when the GrammarTest was created).
    def check_winner(winner)
      competition = @hypothesis.system.gen(winner.input)
      # find the most harmonic candidates
      mh = MostHarmonic.new(competition, @hypothesis.grammar.hierarchy)
      # find optima with output distinct from the winner
      alt_list = []
      winner_optimal = false
      mh.each do |cand|
        if cand.output!=winner.output then
          # TODO: screen out alternatives with violation profiles identical
          #       to the winner's.
          alt_list << cand # a candidate other than the winner is an optimum
        else
          winner_optimal = true # the winner is an optimum
        end
      end
      return alt_list, winner_optimal
    end
    
    def to_s
      out_str = ''
      @failed_winner_info_list.each do |fw_info|
        desired_opt = fw_info.failed_winner
        alt_opts = fw_info.alt_optima
        if fw_info.winner_optimal? then win_s = 'not sole optimum:'
        else win_s = 'not optimal:'
        end
        out_str += "#{desired_opt.input.to_s} --> #{desired_opt.output.to_s}" +
          " #{win_s}  (#{desired_opt.morphword}: "
        continue_space = ' '*((desired_opt.input.to_s.size)+5)
        lex_match = desired_opt.dup
        OTLearn::match_input_to_uf!(lex_match)
        out_str += "#{lex_match.input.to_s})\n"
        alt_opts.each{|opt| out_str += "#{continue_space}#{opt.output.to_s}\n"}
      end
      return out_str
    end
    
  end # class GrammarTest

  # Objects of this class contain the results of evaluation of a set
  # of winners with respect to a hypothesis. It is a subclass of GrammarTest;
  # unlike GrammarTest, this class evaluates winners while leaving input
  # features unset if they are unset in the lexicon.
  #
  # How unset input features are evaluated depends upon the definition of
  # the constraints. The original SL system treated unset input features
  # as invisible: an unset input feature F vacuously satisfied Ident(F).
  class GrammarTestUnsetInputs < GrammarTest
    # Overrides the #check_all() method of GrammarTest.
    def check_all
      # Set each input feature to the value of its underlying correspondent,
      # making it unset if the underlying correspondent is unset.
      @winners.each{|word| OTLearn::match_input_to_uf!(word)}
      # Check each winner, adding it to the failed winner list if it is not
      # the sole optimum with respect to the current hypthesis.
      @winners.each do |word|
        alt_optima, winner_optimal = check_winner(word)
        unless alt_optima.empty?
          @failed_winner_info_list <<
            FailedWinnerInfo.new(word,alt_optima,winner_optimal)
        end
      end
    end    
  end # class GrammarTestUnsetInputs


  # Contains information on a failed winner for a grammar test. A failed
  # winner is a winner which is not a sole optimum with respect to
  # the evaluation hypothesis. It is either non-optimal, or ties for
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

    # Returns the failed winner candidate itself.
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
    def winner_optimal?
      @winner_optimal_flag
    end    
  end # class FailedWinnerInfo

end # module OTLearn
