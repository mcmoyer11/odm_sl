# frozen_string_literal: true

# Author: Bruce Tesar

# Computes the optimal candidates of a competition with respect to
# a hierarchy. Eval is invoked for a specific competition and hierarchy
# by calling the method #find_optima.
# Optimal with respect to a hierarchy is defined by the comparer passed
# in to Eval's constructor.
class Eval
  # Returns a new Eval object, with +comparer+ embedded.
  # The +comparer+ object is assumed to respond to the method
  # #more_harmonic_on_hierarchy, and return one of :FIRST, :SECOND,
  # :TIE, :IDENT_VIOLATIONS.
  # :call-seq:
  #   Eval.new(comparer) -> eval
  def initialize(comparer)
    @comparer = comparer
  end

  # Returns an array of the candidates of +competition+ that are optimal
  # with respect to +hierarchy+.
  # :call-seq:
  #   find_optima(competition, hierarchy) -> arr
  def find_optima(competition, hierarchy)
    optima = []
    competition.each do |cand|
      keep, remove = compare_with_optima(optima, cand, hierarchy)
      optima << cand if keep
      optima -= remove
    end
    optima
  end

  # Compares +cand+ with each of the candidates in +optima+.
  # If +cand+ is less harmonic than one of the optima, it is marked to *not*
  # be added to +optima+. If any of the optima are less harmonic than
  # +cand+, they are marked for later removal from +optima+.
  #
  # Returns array [keep, remove], where keep is a boolean indicating
  # if +cand+ should be added to +optima+, and remove is an array
  # of candidates that should be removed from +optima+.
  def compare_with_optima(optima, cand, hierarchy)
    keep = true
    remove = []
    optima.each do |opt|
      code = @comparer.more_harmonic_on_hierarchy(opt, cand, hierarchy)
      keep = false if code == :FIRST
      remove << opt if code == :SECOND
    end
    [keep, remove]
  end
  private :compare_with_optima
end
