# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require_relative '../../lib/otlearn/induction_learning'

RSpec.describe OTLearn::InductionLearning do
#  before(:each) do
#    @word_list = double("word_list")
#    @grammar = double("grammar")
#    @prior_result = double("prior_result")
#    @language_learner = double("language_learner")
#    
##    @word_list = []
##    @grammar = PAS::Grammar.new
##    @prior_result = []
##    @language_learner = OTLearn::LanguageLearningMMR.new(word_list, grammar)
#    @induction_learning = OTLearn::InductionLearning.new(@word_list, @grammar, @prior_result, @language_learner)
#  end
##
#  it "fails with empty doubles" do
#    expect {@induction_learning.run_induction_learning}.to raise_error(RSpec::Mocks::MockExpectationError)
#  end
  
 #first bring in the right language that will be the test case.
  before(:context) do
    data_file = File.join(File.dirname(__FILE__),'..','..','data','outputs_1r1s_Typology.mar')
    @language_list = read_languages_from_file(data_file) do |label, outputs|
      if label == "LgL7" then
        @l7_outputs = outputs
      end
      if label == "LgL8" then
        @l8_outputs = outputs
      end
    end
  end
  
# Recreate L7/L8 where it should be succeeding with FSF
  context "A new OTLearn::InductionLearning for Language L8" do
    before(:each) do
      @word_list = @l8_outputs
      @grammar = PAS::Grammar.new
      @prior_result = double("prior result")
      allow(@prior_result).to receive(:failed_winners).and_return(@failed_winners)
      
      @winners = @word_list.map{|out| @grammar.system.parse_output(out, @grammar.lexicon)}
      #@language_learner = OTLearn::LanguageLearningMMR.new(@word_list, @grammar)      
      #get the learning up to the point of induction
      OTLearn::ranking_learning_faith_low(@winners, @grammar)
      @prior_result << OTLearn::GrammarTest.new(@winners, @grammar, "Phonotactic Learning")
#      return true if @prior_results.last.all_correct?
#      # Single form UF learning
      run_single_forms_until_no_change(@winners, @grammar)
#      @prior_result << OTLearn::GrammarTest.new(@winners, @grammar, "Single Form Learning")
#      #return true if @prior_result.last.all_correct?
#      # Pursue further learning until the language is learned, or no
#      # further improvement is made.
#      learning_change = true
#      #then contrast pairs
#      contrast_pair = run_contrast_pair(@winners, @grammar, @prior_result.last)
#      unless contrast_pair.nil?
#        @prior_result << OTLearn::GrammarTest.new(@winners, @grammar, "Contrast Pair Learning")
#        learning_change = true
#      end
      @language_learner = double("language_learner")
      allow(@language_learner).to receive(:outputs).and_return(@word_list)
      allow(@language_learner).to receive(:grammar).and_return(@grammar)
      @induction_learning = OTLearn::InductionLearning.new(@winners, @grammar, @prior_result, @language_learner)
      end
    
    it "should pass induction learning" do
      expect(@induction_learning.run_induction_learning).to be true
    end
       

  
  end

  
  
  
  #build L8
#  before(:each) do
#    allow
#  end
  
  
  
end #describe

