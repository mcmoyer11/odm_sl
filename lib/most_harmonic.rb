# Author: Bruce Tesar
#

require 'set'

# A MostHarmonic object represents the most harmonic candidates of
# a competition with respect to a stratified constraint hierarchy, using
# the CTie comparison criterion. It is a subclass of Array, and is an array
# of the most harmonic candidates. It also indicates whether any pairs
# of the most harmonic candidates conflict on the constraints of single
# stratum in the hierarchy.
class MostHarmonic < Array
  P1 = :P1
  P2 = :P2
  TIE = :TIE
  CONFLICT = :CONFLICT

  # Returns a new MostHarmonic object containing the most harmonic candidates
  # of the competition _comp_ with respect to the stratified constraint
  # hierarchy _hier_.
  def initialize(comp, hier)
    @competition = comp
    @hierarchy = hier
    mh_list, @conflict_flag = most_harmonic_on_hierarchy(@competition, @hierarchy)
    self.concat(mh_list)
  end

  # Returns true if two or more of the most harmonic candidates conflict
  # on a stratum of the constraint hierarchy.
  def unresolved_conflict?
    @conflict_flag
  end

  # Returns the complete competition that was evaluated.
  def competition
    @competition
  end

  # Returns the stratified constraint hierarchy that was the basis
  # for the harmonic evaluation.
  def hierarchy
    @hierarchy
  end
  
  # Compares two candidates on a stratum, using the CTie criterion
  # for comparison.
  # Return codes:
  # P1  stratum prefers cand1
  # P2  stratum prefers cand2
  # TIE  the candidates tie on every constraint in the stratum
  # CONFLICT  each candidate is prefered by at least one constraint
  def compare_on_stratum(cand1, cand2, stratum)
    prefer_1 = false
    prefer_2 = false
    stratum.each do |con|
      if cand1.get_viols(con) < cand2.get_viols(con)
        prefer_1 = true
      elsif cand1.get_viols(con) > cand2.get_viols(con)
        prefer_2 = true
      end
    end
    #
    return TIE unless prefer_1 || prefer_2
    return CONFLICT if prefer_1 && prefer_2
    return P1 if prefer_1
    return P2
  end
  
  # Returns a list of those members of the given competition
  # that are most harmonic on the given stratum, using CTie. It also
  # returns a conflict_flag, indicating if the most harmonic candidates
  # conflict on the constraints of the stratum.
  # The CTie comparison criterion is employed such that a candidate
  # is not most harmonic if it is harmonically bound by another candidate
  # on the stratum. If more than one candidate is most harmonic, it can
  # either be because they TIE (identical violations on the stratum)
  # or because they CONFLICT on the stratum (each candidate is prefered
  # by at least one constraint in the stratum).
  def most_harmonic_on_stratum(comp, stratum)
    mh_list = []
    conflict_cands = Set.new
    comp.each do |cand|
      keep = true
      remove_list = []
      # For each candidate currently listed as most harmonic
      mh_list.each do |curr|
        # If one of the candidates harmonically bounds the other, it is
        # more harmonic. Otherwise, compare the two on the stratum.
        if curr.harmonically_bounds?(cand) then
          eval = P2
        elsif cand.harmonically_bounds?(curr) then
          eval = P1
        else
          eval = compare_on_stratum(cand,curr,stratum)
        end
        #
        if (eval==P2) then
          keep = false # If curr is more harmonic, don't keep cand.
        elsif (eval==P1) then
          remove_list << curr # If cand is more harmonic, remove curr from most harmonic list.
        elsif (eval==CONFLICT)
          conflict_cands << cand << curr
        end
      end
      mh_list = mh_list - remove_list
      mh_list << cand if keep
    end
    conflict_flag = mh_list.any? { |c| conflict_cands.member?(c) }    
    return mh_list, conflict_flag
  end
  
  # Returns a list of most harmonic candidates and a boolean conflict flag.
  # The list contains the candidates of the given competition that are
  # most harmonic on the given hierarchy. The conflict flag is true if
  # there is more than one most harmonic candidate and they conflict on
  # constraints within a stratum.
  # The comparison uses the CTie comparison criterion; it evaluates with
  # respect to the hierarchy starting from the top stratum. If a stratum
  # is reached which contains constraints that conflict on still-viable
  # candidates, evaluation halts, and all still-viable candidates are
  # returned.
  def most_harmonic_on_hierarchy(comp, hierarchy)
    mh_list = comp
    conflict_flag = false
    hierarchy.each do |stratum|
      mh_list, conflict_flag = most_harmonic_on_stratum(mh_list, stratum)
      break if conflict_flag
    end
    return mh_list, conflict_flag
  end
  
  # Compares two candidates on a hierarchy, using the CTie criterion
  # for comparison.
  # Return codes:
  # P1  hierarchy prefers cand1
  # P2  hierarchy prefers cand2
  # TIE  the candidates tie on every constraint in the hierarchy
  # CONFLICT  the candidates conflict on a stratum
  def compare_on_hierarchy(cand1, cand2, hierarchy)
    conflict_flag = false
    hierarchy.each do |stratum|
      eval = compare_on_stratum(cand1, cand2, stratum)
      return eval unless eval==TIE
    end
    return TIE
  end

  # Returns *true* if _cand1_ is more harmonic than _cand2_
  # with respect to _hierarchy_, using the CTie comparison criterion.
  # Returns false otherwise.
  def more_harmonic?(cand1, cand2, hierarchy)
    P1 == compare_on_hierarchy(cand1, cand2, hierarchy)
  end
  
end # class MostHarmonic
