# Author: Bruce Tesar

require_relative '../../lib/otlearn/failed_winner_info'

RSpec.describe OTLearn::FailedWinnerInfo, :wip do
  let(:failed_winner){double('failed_winner')}
  let(:alt_optima){[]}
  let(:competitor1){double('competitor1')}
  context "a non-optimal winner" do
    before(:each) do
      alt_optima << competitor1
      @failed_winner_info = OTLearn::FailedWinnerInfo.new(failed_winner, alt_optima, false)
    end
    it "returns the failed winner" do
      expect(@failed_winner_info.failed_winner).to eq failed_winner
    end
    it "returns an alt_optima list with competitor1" do
      expect(@failed_winner_info.alt_optima).to eq [competitor1]
    end
    it "is not optimal" do
      expect(@failed_winner_info.winner_optimal_flag).to be false
    end
  end

end # RSpec.describe OTLearn::FailedWinnerInfo
