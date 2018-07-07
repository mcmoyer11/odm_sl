# Author: Bruce Tesar

require 'otlearn/contrast_pair_learning'
require 'otlearn/language_learning'

RSpec.describe OTLearn::ContrastPairLearning do
  let(:winner_list){double('winner_list')}
  let(:output_list){double('output_list')}
  let(:grammar){double('grammar')}
  let(:prior_result){double('prior_result')}
  let(:otlearn_module){double('OTLearn module')}
  let(:first_cp){double('first_cp')}
  let(:second_cp){double('second_cp')}
  let(:grammar_test_class){double('grammar_test_class')}
  let(:grammar_test){double('grammar_test')}
  before(:each) do
    allow(output_list).to receive(:map).and_return(winner_list)
  end

  context "with first pair informative" do
    before(:each) do
      # The block defines the internal behavior of the test double.
      # The method needs to call #yield on the parameter +result+ passed in
      # by Enumerator.new().
      allow(otlearn_module).to receive(:generate_contrast_pair) do |result, win_list, grammar, p_result|
        result.yield first_cp
      end
      allow(otlearn_module).to receive(:set_uf_values).with(first_cp,grammar).and_return(["feat1"])
      allow(otlearn_module).to receive(:new_rank_info_from_feature).with(grammar,winner_list,"feat1")
      allow(grammar_test_class).to receive(:new).and_return(prior_result, grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(false)
      @contrast_pair_learning =
        OTLearn::ContrastPairLearning.new(output_list, grammar,
        learning_module: otlearn_module, grammar_test_class: grammar_test_class)
    end
    it "returns the first pair" do
      expect(@contrast_pair_learning.contrast_pair).to eq first_cp
    end
    it "checks for ranking information wih feat1" do
      expect(otlearn_module).to have_received(:new_rank_info_from_feature).with(grammar,winner_list,"feat1").exactly(1).times
    end
    it "changes the grammar" do
      expect(@contrast_pair_learning).to be_changed
    end
    it "runs a grammar test before and after learning" do
      expect(grammar_test_class).to have_received(:new).exactly(2).times
    end
    it "gives the grammar test result" do
      expect(@contrast_pair_learning.test_result).to eq grammar_test
    end
    it "indicates that not all words are handled correctly" do
      expect(@contrast_pair_learning).not_to be_all_correct
    end
    it "has step type CONTRAST_PAIR" do
      expect(@contrast_pair_learning.step_type).to \
        eq OTLearn::LanguageLearning::CONTRAST_PAIR      
    end
  end

  context "with one uniformative pair" do
    before(:each) do
      # The block defines the internal behavior of the test double.
      # The method needs to call #yield on the parameter +result+ passed in
      # by Enumerator.new().
      allow(otlearn_module).to receive(:generate_contrast_pair) do |result, win_list, grammar, p_result|
        result.yield first_cp
      end
      allow(otlearn_module).to receive(:set_uf_values).with(first_cp,grammar).and_return([])
      allow(otlearn_module).to receive(:new_rank_info_from_feature)
      allow(grammar_test_class).to receive(:new).and_return(prior_result, grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(false)
      @contrast_pair_learning =
        OTLearn::ContrastPairLearning.new(output_list, grammar,
        learning_module: otlearn_module, grammar_test_class: grammar_test_class)
    end
    it "returns no contrast pair" do
      expect(@contrast_pair_learning.contrast_pair).to be_nil
    end
    it "does not check for ranking information" do
      expect(otlearn_module).not_to have_received(:new_rank_info_from_feature)
    end
    it "does not change the grammar" do
      expect(@contrast_pair_learning).not_to be_changed
    end
    it "runs a grammar test before and after learning" do
      expect(grammar_test_class).to have_received(:new).exactly(2).times
    end
    it "gives the grammar test result" do
      expect(@contrast_pair_learning.test_result).to eq grammar_test
    end
    it "indicates that not all words are handled correctly" do
      expect(@contrast_pair_learning).not_to be_all_correct
    end
  end

  context "with the second pair informative" do
    before(:each) do
      # The block defines the internal behavior of the test double.
      # The method needs to call #yield on the parameter +result+ passed in
      # by Enumerator.new().
      allow(otlearn_module).to receive(:generate_contrast_pair) do |result, win_list, grammar, p_result|
        result.yield first_cp
      end
      allow(otlearn_module).to receive(:generate_contrast_pair) do |result, win_list, grammar, p_result|
        result.yield second_cp
      end
      allow(otlearn_module).to receive(:set_uf_values).with(first_cp,grammar).and_return([])
      allow(otlearn_module).to receive(:set_uf_values).with(second_cp,grammar).and_return(["feat1"])
      allow(otlearn_module).to receive(:new_rank_info_from_feature).with(grammar,winner_list,"feat1")
      allow(grammar_test_class).to receive(:new).and_return(prior_result, grammar_test)
      allow(grammar_test).to receive(:all_correct?).and_return(false)
      @contrast_pair_learning =
        OTLearn::ContrastPairLearning.new(output_list, grammar,
        learning_module: otlearn_module, grammar_test_class: grammar_test_class)
    end
    it "returns the second pair" do
      expect(@contrast_pair_learning.contrast_pair).to eq second_cp
    end
    it "checks for ranking information wih feat1" do
      expect(otlearn_module).to have_received(:new_rank_info_from_feature).with(grammar,winner_list,"feat1").exactly(1).times
    end
    it "changes the grammar" do
      expect(@contrast_pair_learning).to be_changed
    end
    it "runs a grammar test before and after learning" do
      expect(grammar_test_class).to have_received(:new).exactly(2).times
    end
    it "gives the grammar test result" do
      expect(@contrast_pair_learning.test_result).to eq grammar_test
    end
    it "indicates that not all words are handled correctly" do
      expect(@contrast_pair_learning).not_to be_all_correct
    end
  end

end # RSpec.describe OTLearn:ContrastPairLearning
