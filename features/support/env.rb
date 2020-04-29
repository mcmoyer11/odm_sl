# Environment information for Cucumber.

# Add the project directory to the loadpath.
# This allows features to be defined with purely project-relative paths,
# e.g., "bin/sl/learn_l20_1r1s.rb".
project_dir = File.expand_path('../../..',__FILE__)
$LOAD_PATH << File.expand_path(project_dir)
