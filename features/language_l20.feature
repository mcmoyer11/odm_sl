Feature: Language L20 is learned

  As a user
  I want to run the learning algorithm on Language L20
  So that I can verify that it is learned correctly

  Scenario: learn the grammar for Language L20
    Given that file "temp/LgL20.csv" does not exist
    When I run "bin/sl/learn_l20_1r1s.rb"
    Then the file "temp/LgL20.csv" is produced
    And "temp/LgL20.csv" is identical to "test/fixtures/LgL20_expected.csv"
