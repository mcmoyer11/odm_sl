# Author: Bruce Tesar
#
# Configuration and helper methods for RSpec.

# If at least one spec is marked as focus, then execute only the
# focus specs. If no specs are marked focus, then execute all of them.
RSpec.configure do |config|
  config.filter_run_when_matching(focus: true)
end