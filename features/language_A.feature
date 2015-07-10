Feature: Language A is learned

  As a user
  I want to run the learning algorithm on Language A
  So that I can verify that it is learned correctly

  Scenario: learn the grammar for Language A
    Given that file "temp/LgA.csv" does not exist
    When I run "bin/r1s1.rb"
    Then the file "temp/LgA.csv" is produced
    And "temp/LgA.csv" is identical to "test/fixtures/LgA_expected.csv"
