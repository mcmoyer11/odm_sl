# Author: Bruce Tesar

require_relative '../lib/erc'

RSpec.describe "An Erc" do
  before(:each) do
    @erc = Erc.new(["C1","C2"])
  end
  context "with two unset constraints" do
    it "should be e for a constraint" do
      expect(@erc.e?("C1")).to be true
    end
    it "should not be W for a constraint" do
      expect(@erc.w?("C1")).not_to be true
    end
    it "should not be L for a constraint" do
      expect(@erc.l?("C1")).not_to be true
    end
  end
  context "with C1 set to W and C2 set to L" do
    before do
      @erc.set_w("C1")
      @erc.set_l("C2")
    end
    it "should be W for C1" do
      expect(@erc.w?("C1")).to be true
    end
    it "should not be L for C1" do
      expect(@erc.l?("C1")).not_to be true
    end
    it "should not be e for C1" do
      expect(@erc.e?("C1")).not_to be true
    end
    it "should be L for C2" do
      expect(@erc.l?("C2")).to be true
    end
    it "should not be W for C2" do
      expect(@erc.w?("C2")).not_to be true
    end
    it "should not be e for C2" do
      expect(@erc.e?("C2")).not_to be true
    end
    context "and C1 reset to e" do
      before do
        @erc.set_e("C1")
      end
      it "should be e for C1" do
        expect(@erc.e?("C1")).to be true
      end
      it "should not be W for C1" do
        expect(@erc.w?("C1")).not_to be true
      end
      it "should not be L for C1" do
        expect(@erc.l?("C1")).not_to be true
      end
    end
  end
end # describe "An Erc"

RSpec.describe "Two Ercs" do
  before do
    @erc1 = Erc.new(["C1","C2"])
    @erc2 = Erc.new(["C1","C2"])
  end
  context "with the same constraint preferences" do
    before do
      @erc1.set_w("C1")
      @erc2.set_w("C1")
      @erc1.set_l("C2")
      @erc2.set_l("C2")
    end
    it "should have the same hash value" do
      expect(@erc1.hash).to eq(@erc2.hash)
    end
  end
  context "with different constraint preferences" do
    before do
      @erc1.set_w("C1")
      @erc2.set_w("C1")
      @erc1.set_l("C2")
      @erc2.set_e("C2")
    end
    it "should not have the same hash value" do
      expect(@erc1.hash).not_to eq(@erc2.hash)
    end
  end
end