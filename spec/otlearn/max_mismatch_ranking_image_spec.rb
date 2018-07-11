# Author: Bruce Tesar

require 'otlearn/max_mismatch_ranking_image'

RSpec.describe OTLearn::MaxMismatchRankingImage, :wip do
  let(:mmr_step){double('mmr_step')}
  context "given an MMR step with one failing winner adopted" do
    let(:failed_winner){double('failed_winner')}
    let(:failed_winner_morphword){'failed_winner_morphword'}
    let(:failed_winner_input){'failed_winner_input'}
    let(:failed_winner_output){'failed_winner_output'}
    before(:each) do
      allow(mmr_step).to receive(:changed?).and_return(true)
      allow(mmr_step).to receive(:failed_winner).and_return(failed_winner)
      allow(failed_winner).to receive(:morphword).and_return(failed_winner_morphword)
      allow(failed_winner).to receive(:input).and_return(failed_winner_input)
      allow(failed_winner).to receive(:output).and_return(failed_winner_output)
      @mmr_image = OTLearn::MaxMismatchRankingImage.new(mmr_step)
    end
    it "indicates the type of substep" do
      expect(@mmr_image[1,1]).to eq "Max Mismatch Ranking"
    end
    it "indicates that MMR changed the grammar" do
      expect(@mmr_image[2,1]).to eq "Grammar Changed: TRUE"
    end
    it "indicates the morphword of the failed winner used" do
      expect(@mmr_image[3,3]).to eq failed_winner_morphword
    end
    it "indicates the input of the failed winner used" do
      expect(@mmr_image[3,4]).to eq failed_winner_input
    end
    it "indicates the output of the failed winner used" do
      expect(@mmr_image[3,5]).to eq failed_winner_output
    end
  end

  context "given a step without a newly set feature" do
    let(:failed_winner){double('failed_winner')}
    before(:each) do
      allow(mmr_step).to receive(:changed?).and_return(false)
      @mmr_image = OTLearn::MaxMismatchRankingImage.new(mmr_step)
    end
    it "indicates the type of substep" do
      expect(@mmr_image[1,1]).to eq "Max Mismatch Ranking"
    end
    it "indicates the MMR did not change the grammar" do
      expect(@mmr_image[2,1]).to eq "Grammar Changed: FALSE"
    end
    it "only contains two rows" do
      expect(@mmr_image.row_count).to eq 2
    end
  end
end # RSpec.describe MaxMismatchRankingImage
