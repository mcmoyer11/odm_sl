# Author: Bruce Tesar
#
# This is a require "shortcut" for the files comprising the module OTLearn.
# If you require this file, you will automatically require all of the files
# in the otlearn subdirectory (and hence the OTLearn module). In addition,
# It is where the main rdoc comments for the module OTLearn are stored.
# They appear immediately above the empty module declaration below.
#
# Using a file like this to include the files of a module reduces the
# number of require lines that scripts using the module need. Also, if
# additional files are added to the module and stored in the subdirectory,
# they will be included automatically in existing scripts using the module.

#-- This is the main rdoc documentation for module OTLearn.
#++
# This module contains classes and methods for learning in OT systems.
# 
# The file lib/otlearn.rb serves to require all of the files in the
# module, so outside scripts calling on the module need only require
# otlearn in order to load all files of the module.
module OTLearn
  # Nothing here, this is just for the rdoc comments immediately above.
  # The content of OTLearn is contained in the files in otlearn/.
end

# Obtain the directory of this file.
this_dir = File.dirname(__FILE__)

# Obtain a list of all the files in the otlearn subdirectory of
# the current directory.
list = [] # Create variable outside the codeblock, so it remains after.
Dir.chdir("#{this_dir}/otlearn") do
  list = Dir['*.rb']
end

# Issue a require command for every file in the subdirectory.
list.each{ |f| require_relative "otlearn/#{f}" }
