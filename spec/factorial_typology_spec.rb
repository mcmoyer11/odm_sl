# frozen_string_literal: true

# Author: Bruce Tesar

require 'rspec'
require_relative '../lib/factorial_typology'

RSpec.describe 'FactorialTypology' do
  let(:hbound_filter) { double('HBound Filter') }
  let(:erc_list_class) { double('erc_list_class') }

  context 'given 1 competition with two non-HB candidates' do
    class MockErcList < Array
      attr_accessor :label
      def add_all(new_ones)
        new_ones.each { |e| self << e }
        true
      end
      def consistent?
        return true if self == [:erc1]
        return true if self == [:erc2]
      end
    end

    before(:each) do
      allow(erc_list_class).to receive(:new).with(no_args) \
                                            .and_return(MockErcList.new)
      comp1 = [:cand1, :cand2]
      contenders1 = [:cand1, :cand2]
      @comp_list = [comp1]
      @contenders_list = [contenders1]
      allow(hbound_filter).to receive(:remove_collectively_bound) \
        .with(comp1).and_return(contenders1)
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(:cand1, contenders1).and_return([:erc1])
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(:cand2, contenders1).and_return([:erc2])
      @factyp = FactorialTypology.new(@comp_list,
                                      erc_list_class: erc_list_class,
                                      hbound_filter: hbound_filter)
    end
    it 'provides the original competition list' do
      expect(@factyp.original_comp_list).to eq @comp_list
    end
    it 'provides the contenders list' do
      expect(@factyp.contender_comp_list).to eq @contenders_list
    end
    it 'provides the correct typology' do
      expect(@factyp.factorial_typology).to eq [[:erc1], [:erc2]]
    end
  end
end
