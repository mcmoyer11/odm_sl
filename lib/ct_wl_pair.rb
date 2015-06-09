# Author: Bruce Tesar
# 

require_relative 'erc'

# This class is a "reduced" winner-loser pair, in which the winner and
# loser are not expected to have their own constraint violations, unlike
# the class Win_lose_pair. The constraint evaluations must be set after
# an object of class CT_wl_pair has been created, and so a CT_wl_pair is
# not frozen upon construction, again unlike a Win_lose_pair (which derives
# the constraint evaluations of the WL pair from the constraint violations
# of the winner and the loser).
# The parameters +winner+ and +loser+ are expected to respond to the methods
# +input+, +output+, and +constraint_list+. CT_wl_pair is derived from Erc,
# and is constructed based on the winner's constraint list.
# This class is designed primarily for use when reading in the contents
# of a Comparative Tableau, where the winner and loser are represented by
# output strings, and the tableau gives the evaluation by each constraint
# of the WL pair, but not the actual number of constraint violations assessed
# to each candidate.
class CT_wl_pair < Erc

  # The winner of the winner-loser pair.
  attr_reader :winner

  # The loser of the winner-loser pair.
  attr_reader :loser

  # +winner+ and +loser+ are expected to respond to the methods +input+,
  # +output+, and +constraint_list+.
  def initialize(winner, loser, label="nolabel")
    @winner = winner
    @loser = loser
    super(@winner.constraint_list, label) # call constructor for Erc
  end

  # Returns a string containing the string representation, separated by
  # spaces, of:
  #   label input winner_output loser_output constraint_preferences
  def to_s
    "#{label} #{@winner.input} #{@winner.output} #{@loser.output} #{prefs_to_s}"
  end

end # class CT_wl_pair
