# Author: Bruce Tesar

require_relative "../../lib/otlearn/grammar_test_image"

RSpec.describe OTLearn::GrammarTestImage, :wip do
  let(:grammar_test){double('grammar_test')}
  let(:grammar){double('grammar')}
  let(:rcd_class){double('rcd_class')}
  let(:rcd_image_class){double('rcd_image_class')}
  let(:result_image){double('result_image')}
  let(:result_sheet){Sheet.new}
  let(:lexicon_image_class){double('lexicon_image_class')}
  let(:lex_image){double('lex_image')}
  let(:lex_sheet){Sheet.new}
  context "given a GrammarTest with 1 ERC, 4 constraints, 2 morphemes and the label TestGT" do
    before(:each) do
      allow(grammar_test).to receive(:label).and_return('TestGT')
      allow(grammar_test).to receive(:grammar).and_return(grammar)
      allow(grammar).to receive(:erc_list).and_return("ercs")
      allow(grammar).to receive(:lexicon).and_return("lexicon")
      allow(rcd_class).to receive(:new).and_return("rcd_result")
      allow(rcd_image_class).to receive(:new).and_return(result_image)
      allow(result_image).to receive(:sheet).and_return(result_sheet)
      allow(lexicon_image_class).to receive(:new).and_return(lex_image)
      allow(lex_image).to receive(:sheet).and_return(lex_sheet)
      # Use an actual Sheet object to mock the component sheets
      result_sheet[1,1] = "Result Image"
      lex_sheet[1,1] = "Lexicon Image"
      @grammar_test_image =
        OTLearn::GrammarTestImage.new(grammar_test, rcd_class: rcd_class,
        rcd_image_class: rcd_image_class,
        lexicon_image_class: lexicon_image_class)
      @image = @grammar_test_image.sheet
      @image.nil_to_blank!
    end
    it "has the label in the first row" do
      expect(@image[1,1]).to eq "TestGT"
    end
    it "has the ERCs starting in the second row, second column" do
      expect(@image[2,2]).to eq "Result Image"
    end
    it "has a blank line after the ERCs" do
      expect(@image[3,2]).to eq " "
    end
    it "has the lexicon next, starting in the second column" do
      expect(@image[4,2]).to eq "Lexicon Image"
    end
  end
end # RSpec.describe OTLearn::GrammarTestImage

