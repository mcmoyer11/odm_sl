# Author: Bruce Tesar
# 
 
require_relative 'competition'
require_relative 'win_lose_pair'

# A comparative tableau is a list of winner-loser pairs. A comparative tableau
# can be queried for a list of the constraints and for a list of the winners
# within the winner-loser pairs. It also has methods to automatically add
# competitions (one winner-loser pair for each loser in the competition),
# and to automatically add competition lists (adds each competition in
# succession).
#
# *NOTE*: it is important that all of the winner-loser pairs in
# the tableau use the same set of constraints.
class Comparative_tableau < Array

  # Construct an empty comparative tableau. A list of
  # constraints can be passed to the constructor; otherwise, once a
  # winner-loser pair is added, the tableau will adopt that pair's
  # constraint list.
  def initialize(label="NoLabel", constraint_list=nil)
    @label = label
    @constraints = constraint_list
  end

  # Returns the label of the tableau.
  def label
    return @label
  end

  # Sets the tableau's label to _label_.
  def label=(label)
    @label = label
  end
  
  # Returns a list of the constraints used in the tableau. If the tableau
  # does not yet have a list of constraints, an empty array is returned.
  #--
  # If a constraint list was passed to initialize(), then return it.
  # Otherwise, the first time constraint_list is called, get the constraint
  # list of the first erc in the tableau. If the tableau is empty, return
  # an empty list (no source of information about constraints).
  def constraint_list
    return @constraints unless @constraints.nil?
    unless self.empty? then
      @constraints = self[0].constraint_list
      return @constraints
    end
    return []
  end

  # Like Array#reject(), but returns a Comparative_tableau.
  #
  # :call-seq:
  #   reject{|obj| block} -> comparative_tableau
  # 
  def reject
    Comparative_tableau.new("CT#reject()").concat(super)
  end

  # Like Array#partition(), but returns two Comparative_tableau instances.
  #
  # :call-seq:
  #   partition{|obj| block} -> [true_comparative_tableau, false_comparative_tableau]
  #
  def partition
    true_array, false_array = super
    true_ct = Comparative_tableau.new("CT#partition() true").concat(true_array)
    false_ct = Comparative_tableau.new("CT#partition() false").concat(false_array)
    return [true_ct, false_ct]
  end
  
  # For the competition _comp_, build a separate winner-loser
  # pair for the winner paired with each of the losers, adding each w-l pair
  # to the comparative tableau. If there are multiple optima, an exception
  # is thrown unless all optima have identical violation profiles, in which
  # case they are merged into a single merged candidate *before* winner-loser
  # pairs are constructed.
  def add_competition(comp)
    unless comp.optima?
      raise CTError, "CT Error\n" +
        "Cannot have a comparative tableau with no optima for an input."
    end
    winner = comp.winners[0]
    if comp.mult_optima?
      # check for identical violation profiles
      opt_list = comp.winners
      unless opt_list.all?{|opt| opt.ident_viols?(opt_list.first)}
        raise CTError, "CT Error\nCannot have a comparative tableau with" +
          " non_equivalent multiple optima for an input."
      end
      # Remove the first optimum in the list and duplicate it; this way
      # the original winner is unaltered.
      winner = (opt_list.shift).dup
      # Merge the rest of the optima into the dup of the first one.
      # The resulting merged optima candidate is referenced by _winner_.
      opt_list.inject(winner) do |merged_cand, next_win|
        merged_cand.add_merge_candidate(next_win)
      end
    end
    losers = comp.losers
    losers.each{|loser| push(Win_lose_pair.new(winner,loser))}
  end

  # For the competition list _clist_, add each competition to the comparative tableau.
  def add_competition_list(clist)
    clist.each{|comp| add_competition(comp)}
  end
  
  # Returns an array of the winners (no duplicates) in the comparative tableau.
  def winners
    winners = []
    self.each do |wlp|
      winners << wlp.winner unless winners.member?(wlp.winner)
    end
    return winners
  end

  # Returns a string of the tableau, consisting of the to_s() for each
  # winner-loser pair, separated by newlines.
  def to_s
    self.join("\n")
  end

end # class Comparative_tableau


# Exception class to identify errors raised with respect to the structure
# of comparative tableaux.
class CTError < StandardError
  
end