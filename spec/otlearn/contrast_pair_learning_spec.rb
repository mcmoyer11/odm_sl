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
      @contrast_pair_learning = OTLearn::ContrastPairLearning.new(winner_list, grammar, prior_result)
      @contrast_pair_learning.otlearn_module = otlearn_module
      @run_return_value = @contrast_pair_learning.run
    end
    it "returns the first pair" do
      expect(@run_return_value).to eq first_cp
    end
    it "checks for ranking information wih feat1" do
      expect(otlearn_module).to have_received(:new_rank_info_from_feature).with(grammar,winner_list,"feat1").exactly(1).times
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
      @contrast_pair_learning = OTLearn::ContrastPairLearning.new(winner_list, grammar, prior_result)
      @contrast_pair_learning.otlearn_module = otlearn_module
      @run_return_value = @contrast_pair_learning.run
    end
    it "returns nil" do
      expect(@run_return_value).to be_nil
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
      @contrast_pair_learning = OTLearn::ContrastPairLearning.new(winner_list, grammar, prior_result)
      @contrast_pair_learning.otlearn_module = otlearn_module
      @run_return_value = @contrast_pair_learning.run
    end
    it "returns the second pair" do
      expect(@run_return_value).to eq second_cp
    end
    it "checks for ranking information wih feat1" do
      expect(otlearn_module).to have_received(:new_rank_info_from_feature).with(grammar,winner_list,"feat1").exactly(1).times
    end
  end

end # RSpec.describe OTLearn:ContrastPairLearning

