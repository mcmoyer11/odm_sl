# Environment information for Cucumber.

# Add the project directory to the loadpath.
# This allows features to be defined with purely project-relative paths,
# e.g., "bin/r1s1.rb".
project_dir = File.expand_path('../../..',__FILE__)
$LOAD_PATH << File.expand_path(project_dir)
