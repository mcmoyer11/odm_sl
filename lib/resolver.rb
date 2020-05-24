# frozen_string_literal: true

# Author: Bruce Tesar
#
# This file resolves file references for the project by adding the root
# directory for /lib to the load path.
# To work properly, this file should itself reside in the top /lib directory.
# It can be accessed relatively from /bin scripts.

# The parent ('..') of the current file is the directory in which the file
# resides.
lib_dir = File.expand_path('..', __FILE__ )

# Add the directory to the top of the load path unless it is already on
# the load path.
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
