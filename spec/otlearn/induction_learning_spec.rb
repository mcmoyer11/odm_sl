# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require_relative '../../lib/otlearn/induction_learning'

RSpec.describe OTLearn::InductionLearning do
  before(:each) do
    @word_list = double("word_list")
    @grammar = double("grammar")
    @prior_result = double("prior_result")
    @language_learner = double("language_learner")  
##    @word_list = []
##    @grammar = PAS::Grammar.new
##    @prior_result = []
##    @language_learner = OTLearn::LanguageLearningMMR.new(word_list, grammar)
#    @induction_learning = OTLearn::InductionLearning.new(@word_list, @grammar, @prior_result, @language_learner)
  end
  
#  it "fails with empty doubles" do
#    expect {@induction_learning.run_induction_learning}.to raise_error(RSpec::Mocks::MockExpectationError)
#  end
  
 #first build L8 at the point when it needs to go into induction learning
  before(:context) do
    data_file = File.join(File.dirname(__FILE__),'..','..','data','outputs_1r1s_Typology.mar')
    @language_list = read_languages_from_file(data_file) do |label, outputs|
      if label == "LgL8" then
        @l8_outputs = outputs
      end
    end
  end
  
# Recreate L8 where it should be succeeding with FSF
  context "A new OTLearn::InductionLearning for Language L8" do
    before(:each) do
      @grammar = PAS::Grammar.new
      
      @l8_outputs.each do |w|
        if w.morphword == "r1s1"
          @r1s1 = w
        end
        if w.morphword == "r1s3"
          @r1s3 = w
        end
        if w.morphword == "r3s1"
          @r3s1 = w
        end
        if w.morphword == "r3s3"
          @r3s3 = w
        end
      end
      
      #create all the syllables 
      @r1 = PAS::Syllable.new
      allow(@r1).to receive(:length_unset?).and_return(true)
      allow(@r1).to receive(:stress_unset?).and_return(true)
      @s1 = PAS::Syllable.new
      allow(@s1).to receive(:stress_unset?).and_return(true)
      @s1.set_short
      @r2 = PAS::Syllable.new
      @r2.set_long
      allow(@r2).to receive(:stress_unset?).and_return(true)
      @s2 = PAS::Syllable.new
      @s2.set_long
      allow(@s2).to receive(:stress_unset?).and_return(true)
      @r3 = PAS::Syllable.new
      allow(@r3).to receive(:length_unset?).and_return(true)
      allow(@r3).to receive(:stress_unset?).and_return(true)
      @s3 = PAS::Syllable.new
      @s3.set_short
      allow(@s3).to receive(:stress_unset?).and_return(true)
      @r4 = PAS::Syllable.new
      @r4.set_long
      allow(@r4).to receive(:stress_unset?).and_return(true)
      @s4 = PAS::Syllable.new
      @s4.set_long
      allow(@s4).to receive(:stress_unset?).and_return(true)         
      
      #set up the lexicon
      @lexicon = PAS::Lexicon.new
      @lexicon.add("r1",)
      
      #Set up the ERC list
      @cons = PAS::System.new.initialize_constraints
      @erc_r1s1 = Erc.new(@cons,"r1-s2")
      @erc_r2s1 = Erc.new(@cons,"r2-s1")
      @erc_r1s2 = Erc.new(@cons,"r1-s2")      
      @erc_r2s2 = Erc.new(@cons,"r2-s2")     
     
      
# get the learning up to the point of induction
#      OTLearn::ranking_learning_faith_low(@winners, @grammar)
#      @prior_result << OTLearn::GrammarTest.new(@winners, @grammar, "Phonotactic Learning")
#      return true if @prior_results.last.all_correct?
##      # Single form UF learning
#      run_single_forms_until_no_change(@winners, @grammar)
#      @prior_result << OTLearn::GrammarTest.new(@winners, @grammar, "Single Form Learning")
#      return true if @prior_result.last.all_correct?
     
      @winners = @l8_outputs.map{|out| @grammar.system.parse_output(out, @grammar.lexicon)}
      #@language_learner = OTLearn::LanguageLearningMMR.new(@l8_outputs, @grammar) 
      @language_learner = double("language_learner")
      allow(@language_learner).to receive(:outputs).and_return(@l8_outputs)
      allow(@language_learner).to receive(:grammar).and_return(@grammar)
      @induction_learning = OTLearn::InductionLearning.new(@winners, @grammar, @prior_result, @language_learner)
      end
    
    it "should pass induction learning" do
      expect(@induction_learning.run_induction_learning).to be true
    end
       
    #it "should have 3 ercs"
  
  end

  
  
  
  #build L8
#  before(:each) do
#    allow
#  end
  
  
  
end #describe

