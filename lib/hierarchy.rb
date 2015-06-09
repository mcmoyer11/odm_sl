# Author: Bruce Tesar
# 
 
# A stratified constraint hierarchy. The top stratum of the hierarchy
# is first in the list, and so forth. Each stratum is a list of constraints.
class Hierarchy < Array
  
  # Returns a duplicate hierarchy, with distinct stratum objects,
  # but containing references to the very same constraint objects.
  def dup
    copy = Hierarchy.new
    self.each {|strat| copy << strat.dup}
    return copy
  end

  # Returns a string representation of the hierarchy, with strata
  # delimited by square brackets.
  def to_s
    out_str = ""
    self.each do |stratum|
      out_str << "["
      stratum.each {|con| out_str << con.to_s << " "}
      out_str.chomp!(" ") # remove trailing space
      out_str << "] "
    end
    out_str.chomp!(" ")
  end

end # class Hierarchy
