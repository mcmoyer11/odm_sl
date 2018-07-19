# Author: Bruce Tesar
#
# This acceptance spec runs learning on all 24 SL languages,
# and checks the generated learning outputs against the test fixtures.

project_dir = "C:/Users/Tesar/NetBeansProjects/odm_sl"
sl_fixture_dir = File.join(project_dir,'test','fixtures','sl_learning')
generated_dir = File.join(project_dir,'temp','sl_learning')

RSpec.describe "Running ODL", :acceptance do
  before(:context) do
    load "bin/r1s1_typology.rb"
  end
  
  (1..24).each do |num|
    context "on language L#{num}" do
      before(:example) do
        @success = system "diff #{sl_fixture_dir}/LgL#{num}.csv #{generated_dir}/LgL#{num}.csv"
      end
      
      it "produces output that matches its test fixture" do
        expect(@success).to be true
      end
    end
  end

end # RSpec.describe
