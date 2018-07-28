# Author: Bruce Tesar

require 'sheet'
require 'constraint_preference_image'

# A 2-dimensional sheet representation of a comparative tableau, i.e.,
# a list of ercs, typically winner-loser pairs, and the preference of each
# constraint on each erc.
# 
# The constructor receives two parameters: +ercs+ and +constraints+. These
# are passed as separate parameters so that the sheet can list the erc
# rows in in the order that the ercs appear in +ercs+, and the constraint
# columns can appear in the order that the constraints appear in +constraints+.
#
# This class delegates many methods to a Sheet object, and thus will respond
# to all methods defined in Sheet.
class ComparativeTableauImage

  # The sheet index of the header row
  HEADER_ROW = 1 #:nodoc:

  # The sheet indices of the erc information columns.
  LABEL_COL = 1 #:nodoc:
  INPUT_COL = LABEL_COL + 1 #:nodoc:
  WINNER_COL = INPUT_COL + 1 #:nodoc:
  LOSER_COL = WINNER_COL + 1 #:nodoc:
  FIRST_CONSTRAINT_COL = LOSER_COL + 1 #:nodoc:
  
  # Creates a new comparative tableau image, with a header row, a row for
  # each erc, and columns for ERC label, input, winner, loser, and each
  # constraint.
  # * +ercs+ - the ercs, in the order that their rows will appear.
  # * +constraints+ - the constraints, in the order that their columns will
  #   appear.
  # * +pref_image_class+ - the class of object that will represent the
  #   constraint preferences for the ercs. This parameter has a default
  #   value of ConstraintPreferenceImage, and is used for testing
  #   (dependency injection).
  def initialize(ercs, constraints,
      pref_image_class: ConstraintPreferenceImage)
    @ercs = ercs
    @constraints = constraints
    @pref_image_class = pref_image_class
    @pref_image = @pref_image_class.new(@ercs, @constraints)
    @sheet = Sheet.new
    construct_image
  end

  # Delegate all method calls not explicitly defined here to the sheet object.
  def method_missing(name, *args, &block)
    @sheet.send(name, *args, &block)
  end
  protected :method_missing
  
  # Build the image from its main parts: the column headings, the erc
  # information, and the constraint preferences.
  def construct_image
    construct_column_headings
    construct_erc_info
    add_preference_image
  end
  protected :construct_image
  
  # first row contains the column headers
  def construct_column_headings
    @sheet[HEADER_ROW,LABEL_COL] = "ERC\#"
    @sheet[HEADER_ROW,INPUT_COL] = "Input"
    @sheet[HEADER_ROW,WINNER_COL] = "Winner"
    @sheet[HEADER_ROW,LOSER_COL] = "Loser"
  end
  protected :construct_column_headings
  
  # Construct the erc info for each erc, putting the key elements
  # into the appropriate columns. If an erc is a "pure" erc instead of
  # a winner-loser pair, then the cells for that erc in the Input, Winner,
  # and Loser columns are left with the value nil.
  def construct_erc_info
    @ercs.each_with_index do |erc, row_idx|
      row = HEADER_ROW + row_idx + 1
      @sheet[row,LABEL_COL] = erc.label
      if erc.respond_to?(:winner) then # erc contains a winner and a loser
        @sheet[row,INPUT_COL] = erc.winner.input.to_s
        @sheet[row,WINNER_COL] = erc.winner.output.to_s
        @sheet[row,LOSER_COL] = erc.loser.output.to_s
      else
        @sheet[row,INPUT_COL] = nil
        @sheet[row,WINNER_COL] = nil
        @sheet[row,LOSER_COL] = nil
      end
    end
  end
  protected :construct_erc_info

  # Add the constructed image of the constraint preferences for the ercs,
  # starting from the cell in the header row and the first constraint column
  # (that starting cell becomes the upper left-hand corner of the
  # preference image in the comparative tableau image).
  def add_preference_image
    @sheet.put_range[HEADER_ROW,FIRST_CONSTRAINT_COL] = @pref_image
  end
  protected :add_preference_image
end # class ComparativeTableauImage
