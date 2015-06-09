# Author: Bruce Tesar
# 
 
require_relative 'erc'
require_relative 'rcd'
require_relative 'set_hashable'
require_relative 'fred_step'

# This implements the Fusional Reduction (FRed) algorithm. The returned
# object summarizes the results. There are also class methods that
# are used in FRed, but are useful elsewhere as well.
#
# References:
#
# Prince 2002. {Entailed Ranking Arguments.}[http://roa.rutgers.edu/view.php3?id=627]
# 
# Prince & Brasoveanu 2005. {Ranking and Necessity.}[http://roa.rutgers.edu/view.php3?id=1094]
class Fred

  # Runs FRed on the comparative tableau _ct_, and returns a Fred object
  # summarizing the results.
  #
  # Raises an exception if _ct_ is inconsistent.
  def initialize(ct)
    @rcd_result = Rcd.new(ct)
    raise "Do not call FRed on an inconsistent tableau!" unless @rcd_result.consistent?
    # Use only the explained ercs (leaving out any "all-e" ercs).
    if rcd_result.unex_ercs.empty?
      @ct = ct
    else
      @ct = Comparative_tableau.new(ct.label).concat(@rcd_result.ex_ercs.flatten)
    end
    @label = @ct.label
    @constraints = @ct.constraint_list
    @mib = nil
    @skb = nil
    @skb_support = nil
    @residue_list = []
    @fred_steps_list = []
    @fred_kept_steps = []
    unless @ct.empty? then
      run_fred(@ct)
      sort_kept_ercs_by_rcd # make leading W's line up with rcd's constraint order
    end
  end

  # Returns an erc that is the fusion of the ercs of the comparative
  # tableau _ct_.
  #
  # Each constraint assessment of the fusion is determined from the assessments
  # to that same constraint of each of the factor ercs.
  # * If a constraint is 'L' for any factor, it is 'L' in the fusion.
  # * If a constraint is 'W' for any factor, but not 'L' for any factor,
  #   then it is 'W' in the fusion.
  # * Otherwise, it must be 'e' in all factors, and is 'e' in the fusion.
  def Fred.fuse(ct)
    return nil if ct.empty?
    constraints = ct.constraint_list
    fusion = Erc.new(constraints, "f.#{ct.label}")
    constraints.each do |con|
      if ct.any?{|erc| erc.l?(con)} then
        fusion.set_l(con)
      elsif ct.any?{|erc| erc.w?(con)} then
        fusion.set_w(con)
      end  # constraints are e by default
    end
    return fusion
  end

  # The arrow operator. Returns true if <em>erc1</em> --> <em>erc2</em> is true.
  # 
  # Arrow holds when *both* of these two conditions hold:
  # * every constraint that is W for erc1 is also W for erc2 (W only entails W).
  # * every constraint that is L for erc2 is also L for erc1 (L only entailed by L).
  #
  # For non-trivial ercs, arrow is equivalent to entailment.
  # Trivial ercs: valid ercs are entailed by anything, and invalid ercs
  # entail everything, even when arrow wouldn't hold.
  #--
  # This algorithm exploits the set implementation of ercs:
  # * the set of constraints W for erc1 is a subset of those W for erc2.
  # * the set of constraints L for erc2 is a subset of those L for erc1.
  def Fred.arrow?(erc1, erc2)
    return false unless erc1.w_cons.subset?(erc2.w_cons) # W only entails W
    return false unless erc2.l_cons.subset?(erc1.l_cons) # L only entailed by L
    true
  end

  # Returns the constraints of the system.
  def constraint_list()
    @constraints
  end

  # Returns the label of the Fred object, which is also the label of the
  # comparative tableau on which FRed was run.
  def label
    @label
  end

  # Returns the comparative tableau on which FRed was run.
  def ct
    @ct
  end

  # Returns the Rcd object that resulted from running RCD on the
  # comparative tableau.
  def rcd_result
    @rcd_result
  end

  # Returns a list of all the fred steps (kept and otherwise) that were
  # generated during the course of the algorithm.
  def fred_steps_list
    @fred_steps_list
  end

  # Returns a list of the fred steps that were kept during the course
  # of the algorithm.
  def fred_kept_steps
    @fred_kept_steps
  end

  # Returns the Most Informative Basis (MIB), in a comparative tableau object.
  def mib
    unless @mib then
      @mib = Comparative_tableau.new("MIB.#{@label}")
      @fred_kept_steps.each {|step| @mib << step.fusion}
    end
    return @mib
  end
  
  # Returns the Skeletal Basis (SKB), in a comparative tableau object.
  def skb
    unless @skb then
      @skb = Comparative_tableau.new("#{@label} SKB")
      @fred_kept_steps.each {|step| @skb << step.skb_erc}
    end
    return @skb
  end
  
  # Returns the support for the Skeletal Basis, in a comparative tableau object.
  # The support is a set of ercs from the orginal competitions that are
  # sufficient to determine the skeletal basis.
  def skb_support
    unless @skb_support then
      @skb_support = Comparative_tableau.new("#{@label} SKB Support")
      @fred_kept_steps.each {|step| @skb_support.concat(step.support)}
    end
    return @skb_support
  end
  
  # Find those constraints which prefer L in the fusion of the whole ct (f_ct),
  # and prefer L in the fusion of the total residue (f_tr). These are the
  # constraints that are L in a MIB erc but e in the corresponding SKB erc.
  # This returns a Set of the constraints.
  def Fred.find_skb_l(f_ct, f_tr) #:nodoc:
    f_ct.l_cons & f_tr.l_cons # the intersection of the sets of L-constraints
  end
  
  # Run FRed, leaving calculated values in the instance variables.
  # This procedure runs recursively on smaller and smaller subsets of ct.
  def run_fred(ct)
    # Compute the fusion of the entire comparative tableau.
    fusion = Fred.fuse(ct)
    # Compute the residues and the total residue
    residues = []
    total_residue = Comparative_tableau.new("TR.#{ct.label}")
    fusion.w_cons.each do |con|
      info_loss = ct.find_all{|erc| erc.e?(con)}
      unless info_loss.empty?
        new_residue = Comparative_tableau.new("#{ct.label}.#{con.id}")
        residues << new_residue.concat(info_loss)
        total_residue.concat(info_loss)
      end
    end
    # If the fusion isn't entailed by the total residue, keep it.
    keep_fusion, skb_l = entailment_check(fusion, total_residue)
    new_step = Fred_step.new(fusion, ct, keep_fusion, skb_l)
    @fred_steps_list << new_step
    @fred_kept_steps << new_step if keep_fusion
    # Call FRed on the residues; skip any that are subsets of already-processed
    # residues (aren't new).
    residues.each do |res|
      res_as_set = res.to_set
      if new_residue?(res_as_set)
        run_fred(res)
        @residue_list << res_as_set
      end
    end
    return true # nothing went wrong
  end
  private :run_fred
  
  # Return value of true indicates that the fusion should be part of the MIB.
  # If true, also return a list of constraints that are L in the MIB erc
  # but e in the SKB erc.
  # * f.TR entails F.CT iff #L's are equal between the two.
  # * If only some L's in F.CT have corresponding L's in F.TR, those
  #   L's are removed from the SKB (set to e). All W's retained in SKB.
  def entailment_check(fusion, total_residue)
    return [false, nil] if fusion.triv_valid?
    raise "FRed: CT is inconsistent!" if fusion.triv_invalid?
    return [true, []] if total_residue.empty?
    tr_fusion = Fred.fuse(total_residue)
    arrow = Fred.arrow?(tr_fusion, fusion)
    return [false, nil] if arrow
    return [true, Fred.find_skb_l(fusion, tr_fusion)]
  end
  private :entailment_check

  # Return false if res is a subset of an element of @residue_list.
  # A residue that is a subset of an already-processed residue
  # is redundant, and should be skipped.
  def new_residue?(res)
    not @residue_list.any? {|old_res| res.subset?(old_res)}
  end
  private :new_residue?

  # sort the steps by the sorted constraints
  def sort_kept_ercs_by_rcd
    sorted_cons = @rcd_result.hierarchy.flatten # Convert to a flat list, still in order
    no_w_steps = @fred_kept_steps # save reference to the unsorted list
    @fred_kept_steps = [] # start over with a new list
    sorted_cons.each do |con|
      w_steps, no_w_steps = no_w_steps.partition{|s| s.fusion.w?(con)}
      @fred_kept_steps.concat(w_steps)
    end    
  end
  private :sort_kept_ercs_by_rcd
  
end # class Fred
