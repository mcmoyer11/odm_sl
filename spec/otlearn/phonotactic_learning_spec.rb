# Author: Bruce Tesar

require_relative '../../lib/otlearn/phonotactic_learning'

RSpec.describe OTLearn::PhonotacticLearning do
  context "with a winner list and a grammar" do
    let(:winner_list){double('winner_list')}
    let(:grammar){double('grammar')}
    let(:otlearn_module){double('otlearn_module')}
    before(:each) do
      allow(otlearn_module).to receive(:ranking_learning_faith_low).
        and_return(true)
      @phonotactic_learning =
        OTLearn::PhonotacticLearning.new(winner_list, grammar,
        learning_module: otlearn_module)
    end
    it "calls ranking learning" do
      expect(otlearn_module).to have_received(:ranking_learning_faith_low)
    end
    it "indicates if learning made any changes to the grammar" do
      expect(@phonotactic_learning.changed?).to be true
    end
  end
end # RSpec.describe OTLearn::PhonotacticLearning
