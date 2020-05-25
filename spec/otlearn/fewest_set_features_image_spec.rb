# Author: Bruce Tesar

require 'otlearn/fewest_set_features_image'

RSpec.describe OTLearn::FewestSetFeaturesImage do
  let(:fsf_step){double('fsf_step')}
  let(:failed_winner){double('failed_winner')}
  let(:failed_winner_morphword){'failed_winner_morphword'}
  let(:failed_winner_input){'failed_winner_input'}
  let(:failed_winner_output){'failed_winner_output'}
  before(:each) do
    allow(fsf_step).to receive(:failed_winner).and_return(failed_winner)
    allow(failed_winner).to receive(:morphword).and_return(failed_winner_morphword)
    allow(failed_winner).to receive(:input).and_return(failed_winner_input)
    allow(failed_winner).to receive(:output).and_return(failed_winner_output)    
  end
  context "given a step with a newly set feature" do
    before(:each) do
      allow(fsf_step).to receive(:changed?).and_return(true)
      @fsf_image = OTLearn::FewestSetFeaturesImage.new(fsf_step)
    end
    it "indicates the type of substep" do
      expect(@fsf_image[1,1]).to eq "Fewest Set Features"
    end
    it "indicates the FSF changed the grammar" do
      expect(@fsf_image[2,1]).to eq "Grammar Changed: TRUE"
    end
    it "indicates the morphword of the failed winner used" do
      expect(@fsf_image[3,3]).to eq failed_winner_morphword
    end
    it "indicates the input of the failed winner used" do
      expect(@fsf_image[3,4]).to eq failed_winner_input
    end
    it "indicates the output of the failed winner used" do
      expect(@fsf_image[3,5]).to eq failed_winner_output
    end
  end

  context "given a step without a newly set feature" do
    before(:each) do
      allow(fsf_step).to receive(:changed?).and_return(false)
      @fsf_image = OTLearn::FewestSetFeaturesImage.new(fsf_step)
    end
    it "indicates the type of substep" do
      expect(@fsf_image[1,1]).to eq "Fewest Set Features"
    end
    it "indicates the FSF did not change the grammar" do
      expect(@fsf_image[2,1]).to eq "Grammar Changed: FALSE"
    end
    it "indicates the morphword of the failed winner used" do
      expect(@fsf_image[3,3]).to eq failed_winner_morphword
    end
    it "indicates the input of the failed winner used" do
      expect(@fsf_image[3,4]).to eq failed_winner_input
    end
    it "indicates the output of the failed winner used" do
      expect(@fsf_image[3,5]).to eq failed_winner_output
    end
  end

end # RSpec.describe OTLearn::FewestSetFeaturesImage
