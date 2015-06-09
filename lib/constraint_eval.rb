# Author: Bruce Tesar
#
 
require_relative 'constraint'

# A Constraint_eval is an evaluatable constraint. In addition to a name and
# an ID (which define a generic constraint), an evaluatable constraint
# has a code block which evaluates a candidate and returns the number of
# violations of the constraint in that candidate. The constraint is also
# assigned a type, which classifies it as either a markedness constraint
# or a faithfulness constraint.
class Constraint_eval < Constraint
  MARK  = :markedness    # the markedness constraint type
  FAITH = :faithfulness  # the faithfulness constraint type
  
  # Returns a new constraint with the given name and id, of the specified
  # type, with the provided violation evaluation routine.
  # The parameter _id_ is an abbreviated label used for constructing labels for
  # complex objects, e.g., residues in *FRed*.
  #
  # The parameter _type_ must be one of the constants, or an exception will
  # be raised.
  # * Constraint_eval::MARK     markedness constraint
  # * Constraint_eval::FAITH    faithfulness constraint
  # The block parameter _eval_ is the violation evaluation function; it should
  # take, as a parameter, a candidate, and return the number of times
  # that candidate violates this constraint.
  def initialize(name, id, type, eval)
    super(name, id) # call Constraint.initialize().
    @eval_func_string = eval # store the evaluation function
    # Make sure the parametric type is a correct value, and store a
    # corresponding boolean value in the instance variable @markedness.
    if type == MARK then
      @markedness = true
    elsif type == FAITH then
      @markedness = false
    else
      raise "Type must be either ::MARK or ::FAITH, cannot be #{type}"
    end
  end

  # Returns true if this is a markedness constraint, and false otherwise.
  def markedness?
    return @markedness
  end

  # Returns true if this is a faithfulness constraint, and false otherwise.
  def faithfulness?
    return !@markedness
  end
  
  # Returns the number of times this constraint is violated by the
  # parameter candidate.
  def eval_candidate(cand)
    eval_func = eval @eval_func_string
    eval_func.call(cand) # call the stored code block.
  end
end
