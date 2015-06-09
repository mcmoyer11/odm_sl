# Author: Bruce Tesar
#
 
require_relative 'set_hashable'

# Stores all the relevant information for a step of the FRed algorithm:
# a comparative tableau of the ercs that are the basis for the step,
# the fusion of those ercs, whether or not the fusion is kept as part
# of the MIB, and the L-constraints of the fusion that are dropped (turned
# to 'e') for the corresponding skeletal basis erc.
#
# If the fusion is kept as part
# of the MIB, then this also stores a support for the corresponding
# skeletal basis erc. The support is a subset of the ercs, a subset that
# suffices to support the skeletal basis erc.
class Fred_step

  # Returns a fred_step object from the parameters.
  # fusion:: the fusion of the ercs for the fred step.
  # ct:: a comparative tableau of the ercs for the fred step.
  # keep:: boolean indicating if this step will be kept by FRed.
  # skb_l:: a list of the constraints that are 'L' in the fusion but would
  #         be 'e' in the corresponding skeletal basis erc.
  def initialize(fusion, ct, keep, skb_l)
    @fusion = fusion
    @ct = ct
    @keep = keep
    @skb_l = skb_l
    @skb, @support = nil, nil
    if @keep then
      find_skb
      @support = Comparative_tableau.new(@ct.label)
      find_support
    end
  end

  # Returns the fusion that is the basis for this step.
  def fusion() @fusion end

  # Returns a comparative tableau of the ercs for this step.
  def comp_tableau() @ct end

  # Returns true if this step is kept by FRed; returns false otherwise.
  def keep?() @keep end

  # If this step is kept by FRed, returns the skeletal basis erc for this step.
  # Returns nil otherwise.
  def skb_erc() @skb end

  # If this step is kept by FRed, returns a list of the support ercs for
  # the skeletal basis erc for this step.
  # Returns nil otherwise.
  def support() @support end

  # Finds the skeletal basis erc for this step, stores it in @skb, and
  # returns it.
  def find_skb
    @skb = @fusion.dup
    @skb.label = @ct.label
    @skb_l.each {|con| @skb.set_e(con)}
    return @skb
  end
  private :find_skb

  # Finds a support for the skeletal basis erc in @skb, meaning ercs in @ct
  # that together cover all of the L's of the skeletal basis erc.
  # The support ercs are stored in the list @support. Returns true if
  # a support is found. If a support is not found, fail is raised, because
  # something fundamental is wrong.
  def find_support
    # Get the L-constraints for the skeletal basis erc.
    cons_to_find = Set.new(@skb.l_cons)
    @ct.each do |erc|
      intersect_cons = erc.l_cons & cons_to_find
      unless intersect_cons.empty?
        @support = @support.reject do |supp_mem|
          supp_skb_l = supp_mem.l_cons & @skb.l_cons
          new_skb_l = erc.l_cons & @skb.l_cons
          supp_skb_l.subset?(new_skb_l) # if old support erc has a subset of L's, toss it.
        end
        @support << erc
        cons_to_find -= intersect_cons
      end
      return true if cons_to_find.empty? # a full support has been found
    end
    fail # A support should be guaranteed to exist
  end
  private :find_support

  def to_s
    out_s = "Fred step #{@ct.label} KEEP? #{@keep.to_s}" +
      "\nFUS: #{@fusion.to_s}"
    if @keep then
      out_s += "\nSKB: #{@skb.to_s}\nSKB Support:\n#{@support.to_s}"
    end
    out_s + "\n"
  end

end # class Fred_step
