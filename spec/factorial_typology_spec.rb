# frozen_string_literal: true

# Author: Bruce Tesar
#
# The class ErcList is mocked by an internal class, rather than a test
# double, so that it can accumulate some values as an array. The class
# MockErcList is partially defined in the top RSpec scope. But part of
# its behavior needs to be context-dependent, so the rest of the class
# specification, for the method #consistent?, is given within the before
# statement of each test context. It is important that it go within
# the before statement, not just inside the context, so that the
# class declaration is re-run before each test; otherwise, the
# declarations are only run once, when the file is first read, and
# the last one read will determine the definition of #consistent? used
# for *all* of the tests in all environments.
#
# Several of the entities in the tests do not need any state or behavior,
# they just need to be identifiable. Instead of using full test doubles,
# the tests below use symbols as simple, unique designators for
# objects being passed into and out of objects. This is important for
# the Erc mock objects, because they need to be identifiable in the
# method MockErcList#consistent?, but they won't necessarily be accessible
# at the time the method is defined.

require 'rspec'
require_relative '../lib/factorial_typology'

RSpec.describe 'FactorialTypology' do
  let(:hbound_filter) { double('HBound Filter') }
  let(:erc_list_class) { double('erc_list_class') }
  class MockErcList < Array
    attr_accessor :label
    def add_all(new_ones)
      concat(new_ones)
    end
  end

  context 'given 1 competition with two non-HB candidates' do
    before(:each) do
      class MockErcList
        # determine what erc lists are consistent in this context
        def consistent?
          return true if self == [:erc1]
          return true if self == [:erc2]
          false
        end
      end
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

  context 'given 1 competition with 1 non-HB and 1 HB candidate' do
    before(:each) do
      class MockErcList
        # determine what erc lists are consistent in this context
        def consistent?
          return true if self == [:erc1]
          return true if self == [:erc2]
          false
        end
      end
      allow(erc_list_class).to receive(:new).with(no_args) \
                                            .and_return(MockErcList.new)
      comp1 = [:cand1, :cand2]
      contenders1 = [:cand2]
      @comp_list = [comp1]
      @contenders_list = [contenders1]
      allow(hbound_filter).to receive(:remove_collectively_bound) \
        .with(comp1).and_return(contenders1)
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(:cand2, contenders1).and_return([:erc2])
      @factyp = FactorialTypology.new(@comp_list,
                                      erc_list_class: erc_list_class,
                                      hbound_filter: hbound_filter)
    end
    it 'provides the original competition list' do
      expect(@factyp.original_comp_list).to eq @comp_list
    end
    it 'provides just one contender' do
      expect(@factyp.contender_comp_list).to eq @contenders_list
    end
    it 'provides a typology with a single language' do
      expect(@factyp.factorial_typology).to eq [[:erc2]]
    end
  end

  context 'given 2 competitions with one inconsistent combination' do
    before(:each) do
      class MockErcList
        # Determine what erc lists are consistent in this context.
        # One of the four cross-competition combinations is not consistent:
        # [:erc12, :erc22]
        def consistent?
          return true if self == [:erc11]
          return true if self == [:erc12]
          return true if self == [:erc11, :erc21]
          return true if self == [:erc11, :erc22]
          return true if self == [:erc12, :erc21]
          false
        end
      end
      allow(erc_list_class).to receive(:new).with(no_args) \
                                            .and_return(MockErcList.new)
      comp1 = [:cand11, :cand12]
      contenders1 = [:cand11, :cand12]
      comp2 = [:cand21, :cand22]
      contenders2 = [:cand21, :cand22]
      @comp_list = [comp1, comp2]
      @contenders_list = [contenders1, contenders2]
      allow(hbound_filter).to receive(:remove_collectively_bound) \
        .with(comp1).and_return(contenders1)
      allow(hbound_filter).to receive(:remove_collectively_bound) \
        .with(comp2).and_return(contenders2)
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(:cand11, contenders1).and_return([:erc11])
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(:cand12, contenders1).and_return([:erc12])
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(:cand21, contenders2).and_return([:erc21])
      allow(erc_list_class).to receive(:new_from_competition) \
        .with(:cand22, contenders2).and_return([:erc22])
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
      expect(@factyp.factorial_typology).to eq \
        [[:erc11, :erc21], [:erc11, :erc22], [:erc12, :erc21]]
    end
  end
end
