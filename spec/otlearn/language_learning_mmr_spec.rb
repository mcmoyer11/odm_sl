# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require_relative '../../lib/otlearn/language_learning_mmr'
require_relative '../../lib/otlearn/language_learning'
require_relative '../../lib/otlearn/learning_exceptions'

# Read languages from a Marshal-format file, successively yielding
# the label and outputs of each language.
def read_languages_from_file(data_file)
  File.open(data_file, 'rb') do |fin|
    until fin.eof do
      label, outputs = Marshal.load(fin)
      yield label, outputs
    end
  end  
end

RSpec.describe OTLearn::LanguageLearningMMR do
  before(:context) do
    data_file = File.join(File.dirname(__FILE__),'..','..','data','outputs_1r1s_Typology.mar')
    @language_list = read_languages_from_file(data_file) do |label, outputs|
      if label == "LgL20" then
        @l20_outputs = outputs
      end
      if label == "LgL32" then
        @l32_outputs = outputs
      end
      if label == "LgL45" then
        @l45_outputs = outputs
      end
    end
  end
  
  before(:each) do
    @grammar = PAS::Grammar.new
  end
  
context "when given an empty list of outputs to LanguageLearningMMR" do
  before(:each) do
    @outputs = []
    @language_learning_mmr = OTLearn::LanguageLearningMMR.new(@outputs,@grammar)
  end
   
  it "returns true when given empty list of outputs" do
    expect(@language_learning_mmr.learning_successful?).to be true
  end

  it "finds L45" do
    expect(@l45_outputs).not_to be nil
  end
end

context "when given an empty list of outputs to LanguageLearningMMR" do
  before(:each) do
    @outputs = []
    @language_learning = OTLearn::LanguageLearning.new(@outputs,@grammar)
  end
   
  it "returns true when given empty list of outputs" do
    expect(@language_learning.learning_successful?).to be true
  end
end

  #Start by testing a case where both non-MMR and MMR succeed, i.e. L20
  context "when testing L20 with LanguageLearningMMR" do
    before(:each) do
      @language_learning_mmr = OTLearn::LanguageLearningMMR.new(@l20_outputs,@grammar)
    end
    it "succeeds in learning" do
      expect(@language_learning_mmr.learning_successful?).to be true
    end
  end
  
  context "when testing L20 with LanguageLearning" do
    before(:each) do
      @language_learning = OTLearn::LanguageLearning.new(@l20_outputs,@grammar)
    end
    it "succeeds in learning" do
      expect(@language_learning.learning_successful?).to be true
    end
  end

  #Testing cases where the two methods come apart in success/failure, L32
  context "when testing L32 with LanguageLearningMMR" do
    it "succeeds in learning" do
      pending "still working on this" 
      @language_learning_mmr = OTLearn::LanguageLearningMMR.new(@l32_outputs,@grammar)
      expect(@language_learning_mmr.learning_successful?).to be true
    end
  end
  
  context "when testing L32 with LanguageLearning" do
    it "raises an exception" do
      expect {OTLearn::LanguageLearning.new(@l32_outputs,@grammar)}.to raise_error(LearnEx)
    end
  end
  
  #Testing the case where all methods are failing, L45
  context "when testing L45 with LanguageLearning" do
    it "raises an exception" do
      expect {OTLearn::LanguageLearning.new(@l45_outputs,@grammar)}.to raise_error(LearnEx)
    end
  end


end #RSpec.describe


