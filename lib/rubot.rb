# Author: Bruce Tesar
# 
# The purpose of this file is to allow source files from the RUBOT
# project to be included in files of this project. It adds the lib directory
# to the $: searchpath, as a relative path from the directory containing
# this file to RUBOT\lib. This assumes that this file is in the current
# project's top-level /lib directory, and that the project directories of
# the current project and RUBOT are siblings in the same parent directory.
# 
# Usage:
# Require rubot FIRST in your source, then include files from RUBOT.
# 
# Example:
# require_relative '../lib/rubot'
# require 'constraint' 
 
$:.unshift File.join(File.dirname(__FILE__),'..','..','RUBOT','lib')
