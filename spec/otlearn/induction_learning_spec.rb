# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require_relative '../../lib/otlearn/induction_learning'

RSpec.describe OTLearn::InductionLearning do
  before(:each) do
    word_list = []
    grammar = double
    prior_result = double
    language_learner = double
    @induction_learning = OTLearn::InductionLearning.new(word_list, grammar, prior_result, language_learner)
  end

  it "fails with empty doubles" do
    pending
    expect(@induction_learning.run_induction_learning).to be true
  end
end

