# Author: Bruce Tesar

require_relative '../../lib/otgeneric/erc_conversion'

RSpec.describe(OTGeneric::Erc_conversion,"OTGeneric::Erc_conversion.arrays_to_erc_list") do
  context "given a header array and an array with 2 ERCs" do
    before(:example) do
      headers = ['','Con1','Con2','Con3']
      data = [['E1','W','L','W'],['E2','e','W','L']]
      @erc_conversion = OTGeneric::Erc_conversion.arrays_to_erc_list(headers, data)
    end
    it "returns an erc list with 3 constraints" do
      expect(@erc_conversion.constraint_list.size).to eq(3)
    end
    it "returns a constraint list of ['Con1', 'Con2', 'Con3']" do
      con_names = @erc_conversion.constraint_list.map{|c| c.name}
      expect(con_names).to contain_exactly('Con1','Con2','Con3')
    end
    it "returns an erc list with 2 ERCs" do
      expect(@erc_conversion.size).to eq(2)
    end
    context "the first returned ERC" do
      before(:example) do
        @erc1 = @erc_conversion.to_a[0]
      end
      it "is of class Erc" do
        expect(@erc1).to be_an_instance_of(Erc)
      end
      it "has label E1" do
        expect(@erc1.label).to eq('E1')
      end
      it "has Con1 and Con3 as the winner preferrers" do
        winner_names = @erc1.w_cons.map{|c| c.name}
        expect(winner_names).to contain_exactly('Con1','Con3')
      end
      it "has Con2 as the loser preferrer" do
        loser_names = @erc1.l_cons.map{|c| c.name}
        expect(loser_names).to contain_exactly('Con2')
      end
    end
    context "the second returned ERC" do
      before(:example) do
        @erc2 = @erc_conversion.to_a[1]
      end
      it "has label E2" do
        expect(@erc2.label).to eq('E2')
      end
      it "has Con2 as the winner preferrer" do
        winner_names = @erc2.w_cons.map{|c| c.name}
        expect(winner_names).to contain_exactly('Con2')
      end
      it "has Con3 as the loser preferrer" do
        loser_names = @erc2.l_cons.map{|c| c.name}
        expect(loser_names).to contain_exactly('Con3')
      end
    end
  end
end # RSpec.describe
