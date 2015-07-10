# Author: Bruce Tesar
# 

Given(/^that file "([^"]*)" does not exist$/) do |filename|
  File.delete(filename) if File.exist?(filename)
  expect(File.exist?(filename)).to be false
end

When(/^I run "([^"]*)"$/) do |exec_file|
  # system() runs the given command in a subshell, returning
  # a boolean indicating if execution was successful or not.
  successful_run = system("ruby #{exec_file}")
  expect(successful_run).to be true
end

Then(/^the file "([^"]*)" is produced$/) do |created_file|
  expect(File.exist?(created_file)).to be true
end

Then(/^"([^"]*)" is identical to "([^"]*)"$/) do |generated_file, expected_file|
  generated = IO.read(generated_file) # reads the entire file into a string
  expected = IO.read(expected_file)
  expect(generated).to eq(expected)
end
