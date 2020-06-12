# frozen_string_literal: true

# Author: Bruce Tesar
#
# This file resolves file references for the project by adding the root
# directory for /lib to the load path.
# To work properly, this file should itself reside in the top /lib directory.
# It can be accessed relatively from /bin scripts.

# A module for constants with project-wide scope.
# TODO: make ODL the top-level namespace for all of the source files in /lib.
module ODL

  # Constant for the lib directory (containing all the core source files).
  #--
  # __dir__ returns the path of the directory containing the current source
  # file, which should be lib/odl. The parent of that is the lib directory.
  LIB_DIR = File.expand_path('..', __dir__)

  # Add the lib directory to the top of the load path unless it is already
  # on the load path. This way, require statements can refer to source
  # files via their namespace structure.
  $LOAD_PATH.unshift(LIB_DIR) unless $LOAD_PATH.include?(LIB_DIR)

  # Constant for the project directory.
  PROJECT_DIR = File.expand_path('..', LIB_DIR)

  # Constant for the data directory.
  DATA_DIR = File.expand_path('data', PROJECT_DIR)
  # Create the data directory if it doesn't already exist.
  Dir.mkdir(DATA_DIR) unless Dir.exist?(DATA_DIR)

  # Constant for the temp directory.
  TEMP_DIR = File.expand_path('temp', PROJECT_DIR)
  # Create the temp directory if it doesn't already exist.
  Dir.mkdir(TEMP_DIR) unless Dir.exist?(TEMP_DIR)
end
