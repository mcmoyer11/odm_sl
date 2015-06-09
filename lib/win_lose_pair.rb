# Author: Bruce Tesar
#
 
require_relative 'erc'
require_relative 'candidate'
require 'english'

# A winner-loser pair has a winner, a loser, and the resulting erc.
# Once created, Win_lose_pair objects are frozen, so that the set_w, etc.
# methods of Erc cannot be used to change the constraint preferences.
class Win_lose_pair < Erc

  # The winner of the winner-loser pair.
  attr_reader :winner

  # The loser of the winner-loser pair.
  attr_reader :loser

  # Stores +winner+ and +loser+, and constructs an +Erc+ based on the
  # constraint violations of each. The returned object is frozen.
  #
  # ==== Exceptions
  #
  # RuntimeError - if +winner+ and +loser+ do not have the same input.
  def initialize(winner, loser)
    if (winner.input != loser.input) then
      raise("The winner and loser do not have the same input.")
    end
    @winner = winner
    @loser = loser
    # Use a regular expression match to find the input number part of
    # the loser label. Treat what follows as the candidate number part.
    # Global variable $POSTMATCH is set to the part of the string following the match.
    if (@loser.label =~ /^\d+\./) then
      label = @winner.label + ">" + $POSTMATCH
    else
      label = "NoLabel"
    end
    super(winner.constraint_list, label) # call constructor for Erc
    set_constraint_preferences
    freeze
  end

  # Returns a string of the form:
  #
  #   label input winner_output loser_output constraint_preferences
  def to_s
    "#{label} #{@winner.input} #{@winner.merged_outputs_to_s} #{@loser.output} #{prefs_to_s}"
  end

private # the following methods are private, and can only be called from 
        # within the object itself; in this case, called by initialize().

  # For each constraint, determine if it prefers the winner, the loser,
  # or neither, and set the erc appropriately.
  # Called by the constructor +Win_lose_pair.new+.
  def set_constraint_preferences
    constraint_list.each do |con|
      if @winner.get_viols(con) < @loser.get_viols(con) then
        set_w(con)
      elsif @winner.get_viols(con) > @loser.get_viols(con) then
        set_l(con)
      end  # Constraints are e by default in ercs.
    end
  end
  
end # class Win_lose_pair
