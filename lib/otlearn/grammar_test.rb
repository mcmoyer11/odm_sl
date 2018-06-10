# Author: Bruce Tesar
#

require_relative 'uf_learning'
require_relative 'data_manip'
require_relative 'failed_winner_info'

module OTLearn

  # A GrammarTest object holds the results of the evaluation of a set
  # of winners with respect to a grammar. The tests are initiated by
  # creating a GrammarTest; the constructor takes a list of winners and
  # a grammar as parameters.
  #
  # Each winner is a Word, possibly with unset features in the input.
  class GrammarTest

    # Returns a new GrammarTest, for the provided +winners+, and with
    # respect to the provided +grammar+.
    def initialize(winners, grammar, label="NoLabel")
      @label = label
      @system = grammar.system
      # Dup the grammar, so it can be frozen.
      @grammar = grammar.dup
      # Dup the winners, and then adjust their UI correspondence relations
      # to refer to the dup grammar.
      @winners = winners.map{|win| win.dup}
      @winners.each{|win| win.sync_with_grammar!(@grammar)}
      # Generate the test ranking, using "faithfulness low".
      # TODO: inject a hierarchy construction object via the constructor.
      @hierarchy = RcdFaithLow.new(@grammar.erc_list).hierarchy
      # Initialize lists for failed and successful winners
      @failed_winner_info_list = []
      @success_winners = []
      check_all
      # Freeze the test results, so they cannot be accidentally altered later.
      @grammar.freeze
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

    # Returns a reference to the linguistic system in use.
    def system
      @system
    end
    protected :system
    
    # Returns the grammar used in this test.
    # NOTE: returned object is frozen, and cannot be altered.
    # Create a duplicate to alter it.
    def grammar()
      @grammar
    end
    
    # Returns the hierarchy used in the evaluation of winners.
    def hierarchy()
      @hierarchy
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
    def check_winner(winner)
      competition = system.gen(winner.input)
      # find the most harmonic candidates
      mh = MostHarmonic.new(competition, hierarchy)
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
end # module OTLearn
