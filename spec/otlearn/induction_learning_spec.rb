# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require_relative '../../lib/otlearn/induction_learning'
require_relative '../../lib/pas/data'
require_relative '../../lib/pas/syllable'

RSpec.describe OTLearn::InductionLearning, :wp do
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
 #first build L8 at the point when it needs to go into induction learning
  before(:context) do
    data_file = File.join(File.dirname(__FILE__),'..','..','data','outputs_1r1s_Typology.mar')
    language_list = read_languages_from_file(data_file) do |label, outputs|
      if label == "LgL8" then
        @l8_outputs = outputs
      end
    end
  end
  
# Recreate L8 where it should be succeeding with FSF
  context "A new OTLearn::InductionLearning for Language L8" do
    before(:each) do
      @gram = PAS::Grammar.new
      # this populates the lexicon with empty UFs
      # but this also generates all the competitions
      # this does it like at the beginning of learning
      @winner_list = @l8_outputs.map{|out| @gram.system.parse_output(out, @gram.lexicon)}
      @lexicon = @gram.lexicon
      # pull out the lexical_entries that need to have their 
      # underlying features set
      @r3 = @lexicon.find{|m| m.label =="r3"}
      @s3 = @lexicon.find{|m| m.label =="s3"}
      # pull out the first item of each LE, and set the features that need to be set
      @r3.uf[0].set_short
      @s3.uf[0].set_short
      # Set up the ERC list
#      @cons = PAS::System.new.initialize_constraints
#      @erc_r1s1 = Erc.new(@cons,"r1-s2")
#      @erc_r2s1 = Erc.new(@cons,"r2-s1")
#      @erc_r1s2 = Erc.new(@cons,"r1-s2")      
#      @erc_r2s2 = Erc.new(@cons,"r2-s2")
    end
    
    it "the lexicon should not be nil" do
      expect(@lexicon).not_to be_empty
    end  
    
    it "the lexicon should have root r3 with stress feature unset" do
      expect(@r3.uf[0]).to be_stress_unset
    end
    it "the lexicon should have root r3 with length feature short" do
      expect(@r3.uf[0]).to be_length_unset
    end
    it "the lexicon should have root r3 with length feature short" do
      expect(@r3.uf[0]).to be_short
    end
    
    
    
    
  end #context  
    #and then with the ERCS too in the same way
    

  
end #describe

