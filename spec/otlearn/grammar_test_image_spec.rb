# Author: Bruce Tesar

require_relative "../../lib/otlearn/grammar_test_image"
require "sheet"

RSpec.describe OTLearn::GrammarTestImage do
  let(:grammar_test){double('grammar_test')}
  let(:grammar){double('grammar')}
  let(:rcd_class){double('rcd_class')}
  let(:rcd_image_class){double('rcd_image_class')}
  let(:result_image){Sheet.new}
  let(:lexicon_image_class){double('lexicon_image_class')}
  let(:lex_image){Sheet.new}
  context "given a GrammarTest with 1 ERC, 4 constraints, 2 morphemes and the label TestGT" do
    before(:each) do
      allow(grammar_test).to receive(:label).and_return('TestGT')
      allow(grammar_test).to receive(:grammar).and_return(grammar)
      allow(grammar).to receive(:erc_list).and_return("ercs")
      allow(grammar).to receive(:lexicon).and_return("lexicon")
      allow(rcd_class).to receive(:new).and_return("rcd_result")
      allow(rcd_image_class).to receive(:new).and_return(result_image)
      allow(lexicon_image_class).to receive(:new).and_return(lex_image)
      # mock each component image with a single cell
      result_image[1,1] = "Result Image"
      lex_image[1,1] = "Lexicon Image"
      @gt_image =
        OTLearn::GrammarTestImage.new(grammar_test, rcd_class: rcd_class,
        rcd_image_class: rcd_image_class,
        lexicon_image_class: lexicon_image_class)
    end
    it "has the label in the first row" do
      expect(@gt_image[1,1]).to eq "TestGT"
    end
    it "has the ERCs starting in the second row, second column" do
      expect(@gt_image[2,2]).to eq "Result Image"
    end
    it "has a blank line after the ERCs" do
      expect(@gt_image[3,1]).to be_nil
      expect(@gt_image[3,2]).to be_nil
    end
    it "has the lexicon after post-ERC blank line, starting in the second column" do
      expect(@gt_image[4,2]).to eq "Lexicon Image"
    end
  end
end # RSpec.describe OTLearn::GrammarTestImage
