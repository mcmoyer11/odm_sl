# frozen_string_literal: true

# Author: Bruce Tesar

require 'lexicon_image_maker'

RSpec.describe LexiconImageMaker do
  let(:lexicon) { instance_double('Lexicon') }
  let(:pref1) { instance_double('Lexical_Entry', label: 'p1', uf: 'a') }
  let(:root1) { instance_double('Lexical_Entry', label: 'r1', uf: 'x') }
  let(:root2) { instance_double('Lexical_Entry', label: 'r2', uf: 'y') }
  let(:suff1) { instance_double('Lexical_Entry', label: 's1', uf: 'y') }
  let(:sheet_class) { double('sheet class') }
  let(:sheet) { double('sheet') }
  let(:subsheet) { double('subsheet') }
  let(:inner_class) { double('inner_class') }
  before(:example) do
    allow(sheet_class).to\
      receive(:new).and_return(sheet, subsheet, subsheet, subsheet)
    allow(sheet).to receive(:put_range).and_return(inner_class)
    allow(inner_class).to receive(:[]=)
    allow(subsheet).to receive(:[]=)
    @lexicon_image_maker = LexiconImageMaker.new(sheet_class: sheet_class)
  end
  context 'An empty lexicon' do
    before(:each) do
      allow(lexicon).to receive(:get_prefixes).and_return([])
      allow(lexicon).to receive(:get_roots).and_return([])
      allow(lexicon).to receive(:get_suffixes).and_return([])
      @lexicon_image = @lexicon_image_maker.get_image(lexicon)
    end
    it 'gives an image with no subsheets' do
      expect(sheet).not_to have_received(:put_range)
    end
  end

  context 'A lexicon with root r1 /x/' do
    before(:each) do
      allow(lexicon).to receive(:get_prefixes).and_return([])
      allow(lexicon).to receive(:get_roots).and_return([root1])
      allow(lexicon).to receive(:get_suffixes).and_return([])
      @lexicon_image = @lexicon_image_maker.get_image(lexicon)
    end
    it 'gives an image with one subsheet' do
      expect(sheet).to have_received(:put_range).exactly(1).times
    end
    it "puts 'r1' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 1, 'r1')
    end
    it "puts 'x' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 2, 'x')
    end
  end

  context 'A lexicon with root 1 r1 /x/ and root r2 /y/' do
    before(:each) do
      allow(lexicon).to receive(:get_prefixes).and_return([])
      allow(lexicon).to receive(:get_roots).and_return([root1, root2])
      allow(lexicon).to receive(:get_suffixes).and_return([])
      @lexicon_image = @lexicon_image_maker.get_image(lexicon)
    end
    it 'gives an image with one subsheet' do
      expect(sheet).to have_received(:put_range).exactly(1).times
    end
    it "puts 'r1' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 1, 'r1')
    end
    it "puts 'x' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 2, 'x')
    end
    it "puts 'r2' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 4, 'r2')
    end
    it "puts 'x' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 5, 'y')
    end
  end

  context 'A lexicon with root 1 r1 /x/ and suffix s1 /y/' do
    before(:each) do
      allow(lexicon).to receive(:get_prefixes).and_return([])
      allow(lexicon).to receive(:get_roots).and_return([root1])
      allow(lexicon).to receive(:get_suffixes).and_return([suff1])
      @lexicon_image = @lexicon_image_maker.get_image(lexicon)
    end
    it 'gives an image with two subsheets' do
      expect(sheet).to have_received(:put_range).exactly(2).times
    end
    it "puts 'r1' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 1, 'r1')
    end
    it "puts 'x' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 2, 'x')
    end
    it "puts 's1' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 1, 's1')
    end
    it "puts 'y' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 2, 'y')
    end
  end

  context 'A lexicon with prefix p1 /a/, root r1 /x/ and suffix s1 /y/' do
    before(:each) do
      allow(lexicon).to receive(:get_prefixes).and_return([pref1])
      allow(lexicon).to receive(:get_roots).and_return([root1])
      allow(lexicon).to receive(:get_suffixes).and_return([suff1])
      @lexicon_image = @lexicon_image_maker.get_image(lexicon)
    end
    it 'gives an image with three subsheets' do
      expect(sheet).to have_received(:put_range).exactly(3).times
    end
    it "puts 'p1' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 1, 'p1')
    end
    it "puts 'a' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 2, 'a')
    end
    it "puts 'r1' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 1, 'r1')
    end
    it "puts 'x' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 2, 'x')
    end
    it "puts 's1' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 1, 's1')
    end
    it "puts 'x' on a subsheet" do
      expect(subsheet).to have_received(:[]=).with(1, 2, 'y')
    end
  end
end
