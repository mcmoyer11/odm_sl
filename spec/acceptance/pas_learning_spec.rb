# Author: Bruce Tesar
#
# This acceptance spec runs learning on all 62 PAS languages,
# and checks the generated learning outputs against the test fixtures.

# BBT: 4/25/2020 Limiting the acceptance testing to SL for now.

#RSpec.describe "Running ODL on PAS", :acceptance do
#  before(:context) do
#    project_dir = "C:/Users/Tesar/NetBeansProjects/odm_sl"
#    @pas_fixture_dir = File.join(project_dir,'test','fixtures','pas_learning')
#    @generated_dir = File.join(project_dir,'temp','pas_learning')
#    executable_dir = File.join('bin','pas')
#    load "#{executable_dir}/learn_typology_1r1s.rb"
#  end
#  
#  (1..62).each do |num|
#    context "on language L#{num}" do
#      before(:example) do
#        @success = system "diff #{@pas_fixture_dir}/LgL#{num}.csv #{@generated_dir}/LgL#{num}.csv"
#      end
#      
#      it "produces output that matches its test fixture" do
#        expect(@success).to be true
#      end
#    end
#  end
#
#end # RSpec.describe
