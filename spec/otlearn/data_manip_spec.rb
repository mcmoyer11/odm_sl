# Author: Bruce Tesar
#
# Specs for the module methods in OTLearn for data manipulation.
# They module methods are defined in the file otlearn/data_manip.rb.

require 'otlearn/data_manip.rb'
require 'win_lose_pair'

RSpec.describe "OTLearn::wlp_winners()" do
  context "given a single WL pair" do
    before do
      @win1 = instance_double(Candidate)
      pair1 = instance_double(Win_lose_pair)
      allow(pair1).to receive(:winner).and_return(@win1)
      @wlp_list = instance_double(Erc_list)
      allow(@wlp_list).to receive(:each).and_yield(pair1)
    end
    it "returns the winner for that pair" do
      win_list = OTLearn::wlp_winners(@wlp_list)
      expect(win_list).to contain_exactly(@win1)
    end
  end
  
  context "given three WLP pairs, two sharing a winner" do
    before(:example) do
      @win1 = instance_double(Candidate)
      @win2 = instance_double(Candidate)
      pair1 = instance_double(Win_lose_pair)
      pair2 = instance_double(Win_lose_pair)
      pair3 = instance_double(Win_lose_pair)
      allow(pair1).to receive(:winner).and_return(@win1)
      allow(pair2).to receive(:winner).and_return(@win2)
      allow(pair3).to receive(:winner).and_return(@win1)
      @wlp_list = instance_double(Erc_list)
      allow(@wlp_list).to receive(:each).and_yield(pair1)
        .and_yield(pair2).and_yield(pair3)
    end
    it "returns the two distinct winners" do
      win_list = OTLearn::wlp_winners(@wlp_list)
      expect(win_list).to contain_exactly(@win1, @win2)
    end
  end
end # describe DataManipMethod1
