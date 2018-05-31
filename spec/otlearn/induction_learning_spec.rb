# Author: Morgan Moyer / Bruce Tesar

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require_relative '../../lib/otlearn/induction_learning'

RSpec.describe OTLearn::InductionLearning do
  before(:each) do
    word_list = []
    grammar = double("grammar")
    prior_result = double("prior_result")
    language_learner = double("language_learner")
    allow(prior_result).to receive(:failed_winners).and_return([])
    @induction_learning = OTLearn::InductionLearning.new(word_list, grammar, prior_result, language_learner)
  end

  it "raises an exception if no winners fail" do
    expect{@induction_learning.run_induction_learning}.to raise_error(RuntimeError)
  end
  
end

