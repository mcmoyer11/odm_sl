# frozen_string_literal: true

# Author: Bruce Tesar

# A basic OT constraint, consisting of a name, an id, a type, and an
# evaluation procedure for assigning violations to candidates.
# Only the name is compared when constraints are compared for equality.
# The id is an abbreviated label used for constructing labels for
# complex objects.
#
# Constraints are used as keys for hashes (e.g., in ercs), so they should
# not be altered once constructed. It is a good idea to freeze the
# constraint objects once they have been created.
# Ideally, any OT system or analysis should have just a single object for
# each constraint, with all constraint-referring objects containing references
# to those same constraints.
class Constraint
  # the markedness constraint type constant
  MARK  = :markedness

  # the faithfulness constraint type constant
  FAITH = :faithfulness

  # The name of the constraint.
  attr_reader :name

  # The symbol version of the constraint's name.
  attr_reader :symbol

  # The id (an abbreviated label) of the constraint.
  attr_reader :id

  # _name_ is the name of the constraint, ideally a short string.
  # _id_ is an abbreviated label used for constructing labels for
  # complex objects.
  # _type_ must be one of the type constants, or an exception will
  # be raised.
  # * Constraint::MARK     markedness constraint
  # * Constraint::FAITH    faithfulness constraint
  # The block parameter is the violation evaluation function; it should
  # take, as a parameter, a candidate, and return the number of times
  # that candidate violates this constraint.
  # :call-seq:
  #   Constraint.new(name, id, type) {|constraint| ... } -> constraint
  def initialize(name, id, type, &eval)
    @name = name
    @symbol = name.to_sym
    # The name should never change, so calculate the hash value of the
    # name once and store it.
    @hash_value = @name.hash
    @id = id.to_s
    check_constraint_type(type)
    # store the evaluation function (passed as a code block)
    @eval_function = eval
  end

  # Makes sure the parametric type is a correct value, and stores a
  # corresponding boolean value in the instance variable @markedness.
  # Raises an exception if the specified _type_ is neither MARK nor
  # FAITH.
  def check_constraint_type(type)
    if type == MARK
      @markedness = true
    elsif type == FAITH
      @markedness = false
    else
      raise "Type must be either MARK or FAITH, cannot be #{type}"
    end
  end

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
    @markedness
  end

  # Returns true if this is a faithfulness constraint, and false otherwise.
  def faithfulness?
    !@markedness
  end

  # Returns the number of times this constraint is violated by the
  # parameter candidate.
  # Raises a RuntimeError if no evaluation function block was provided at
  # the time the constraint was constructed.
  def eval_candidate(cand)
    if @eval_function.nil?
      msg1 = 'Constraint#eval_candidate: no evaluation function was provided'
      msg2 = 'but #eval_candidate was called.'
      raise "#{msg1} #{msg2}"
    end

    @eval_function.call(cand) # call the stored code block.
  end

  # Returns a string consisting of the constraint's id, followed
  # by a colon, followed by the constraint's name.
  def to_s
    "#{@id}:#{@name}"
  end
end
