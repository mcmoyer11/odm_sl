# Author: Bruce Tesar

require 'factorial_typology'

RSpec.describe FactorialTypology do
  before do
    @competition_list = instance_double(Competition_list)
    allow(@competition_list).to receive(:constraint_list)
    allow(@competition_list).to receive(:each)
    @factorial_typology = FactorialTypology.new(@competition_list)
  end

end # describe FactorialTypology
