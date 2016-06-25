# Author: Bruce Tesar
#

# A basic OT constraint, consisting of a name, an id, a type, and an
# evaluation procedure for assigning violations to candidates.
# Only the name is considered when constraints are compared for equality.
# The id is an abbreviated label used for constructing labels for
# complex objects, e.g., residues in *FRed*.
# Constraints are used as keys for hashes (e.g., in ercs), so they should
# not be altered once constructed. It is a good idea to freeze the
# constraint objects once they have been created.
# Ideally, any OT system or analysis should have just a single object for
# each constraint, with all constraint-referring objects containing references
# to those same constraints.
class Constraint
  # The constraint type constants
  MARK  = :markedness    # the markedness constraint type
  FAITH = :faithfulness  # the faithfulness constraint type
  
  # Returns a constraint.
  # The parameter _id_ is an abbreviated label used for constructing labels for
  # complex objects, e.g., residues in *FRed*.
  # The parameter _type_ must be one of the constants, or an exception will
  # be raised.
  # * Constraint::MARK     markedness constraint
  # * Constraint::FAITH    faithfulness constraint
  # The block parameter _eval_ is the violation evaluation function; it should
  # take, as a parameter, a candidate, and return the number of times
  # that candidate violates this constraint.
  def initialize(name, id, type, eval)
    @name = name
    # Store the symbol version of the name; faster for purposes of #==().
    @symbol = name.to_sym
    # The name should never change, so calculate the hash value of the
    # name once and store it.
    @hash_value = @name.hash
    @id = id.to_s
    # Make sure the parametric type is a correct value, and store a
    # corresponding boolean value in the instance variable @markedness.
    if type == MARK then
      @markedness = true
    elsif type == FAITH then
      @markedness = false
    else
      raise "Type must be either ::MARK or ::FAITH, cannot be #{type}"
    end
    # store the evaluation function
    @eval_func_string = eval
  end

  # Returns the name of the constraint.
  def name() @name end

  # Returns the id of the constraint. The id is an abbreviated label.
  def id() @id end

  # Returns the symbol version of the constraint's name. Only for internal
  # purposes (see #==()).
  def symbol() @symbol end
  protected :symbol

  # Two constraints are equivalent if their names are equivalent.
  def ==(other)
    # Comparing two symbols is faster than comparing two strings.
    @symbol == other.symbol
  end

  # The same as ==
  def eql?(other)
    self == other
  end
  
  # Returns the hash number of the constraint. The hash number
  # for a constraint is the hash number of its name. If two
  # constraints have the same name, they will have the same hash number.
  def hash
    @hash_value
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
  
  # Returns a string consisting of the constraint's id, followed
  # by a colon, followed by the constraint's name.
  def to_s()
    @id + ":" + @name.to_s
  end
  
end  # class Constraint
