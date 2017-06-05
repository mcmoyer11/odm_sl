# Author: Bruce Tesar

require 'otlearn/mrcd'
require_relative '../../test/helpers/quick_erc'

RSpec.describe OTLearn::Mrcd do
  before(:each) do
    @word_list = []
    @hypothesis = nil
    @mrcd = OTLearn::Mrcd.new(@word_list, @hypothesis)
  end

  it "performs phonotactic learning"

end

