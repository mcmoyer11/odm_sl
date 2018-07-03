# Author: Bruce Tesar

require_relative '../../lib/otlearn/contrast_pair_learning'

RSpec.describe OTLearn::ContrastPairLearning, :wip do
  let(:winner_list){double('winner_list')}
  let(:grammar){double('grammar')}
  let(:prior_result){double('prior_result')}
  let(:otlearn_module){double('OTLearn module')}
  let(:first_cp){double('first_cp')}
  let(:second_cp){double('second_cp')}

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
      @contrast_pair_learning =
        OTLearn::ContrastPairLearning.new(winner_list, grammar, prior_result,
        learning_module: otlearn_module)
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
      @contrast_pair_learning =
        OTLearn::ContrastPairLearning.new(winner_list, grammar, prior_result,
        learning_module: otlearn_module)
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
      @contrast_pair_learning =
        OTLearn::ContrastPairLearning.new(winner_list, grammar, prior_result,
        learning_module: otlearn_module)
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
  end

end # RSpec.describe OTLearn:ContrastPairLearning
