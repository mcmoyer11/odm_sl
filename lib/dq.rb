# Author: Bruce Tesar
#

# Surrounds a string with double-quote symbols inside the string.
# Useful for things like Windows paths with spaces in them that
# need to be fed to a command line.
class String
  def dq
    return '"' + self + '"'
  end
end
