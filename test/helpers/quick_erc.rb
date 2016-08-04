# Author: Bruce Tesar

require 'erc'
require 'constraint'

module Test
  # Constants for evaluation by constraints
  ML = "ML"  # prefers the loser
  ME = "Me"  # no preference
  MW = "MW"  # prefers the winner
  FL = "FL"  # prefers the loser
  FE = "Fe"  # no preference
  FW = "FW"  # prefers the winner

  # This is a method for testing. It allows an ERC of a certain form to
  # be constructed in a single, readable line.
  #
  # Test.quick_erc([MW,FL]) returns an ERC with two constraints:
  # * M1, a markedness constraint preferring the winner
  # * F2, a faithfulness constraint preferring the loser
  def Test.quick_erc(evals, label="")
    constraints = Array.new
    erc = Erc.new(constraints, label)
    id = 0
    evals.each do |e|
      id += 1
      md = /(M|F)(W|L|e)/.match(e.to_s)
      raise "Failed to match eval #{e.to_s} in quick_erc" if md.nil?
      if md[1]=='F' then
        con_type = Constraint::FAITH
        con_name = "F#{id.to_s}"
      else
        con_type = Constraint::MARK
        con_name = "M#{id.to_s}"
      end
      con = Constraint.new(con_name, id, con_type)
      constraints << con
      if md[2]=='W' then erc.set_w(con)
      elsif md[2]=='L' then erc.set_l(con)
      else erc.set_e(con)
      end
    end
    return erc
  end

end # module Test