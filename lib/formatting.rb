# Author: Bruce Tesar
# 

# This mixin adds a capacity for storing formatting commands to a class.
# The list is accessible via the #formatting and #add_formatting methods.
# It also defines a collection of classes that define the possible
# formatting commands (each command should be an instance of one of
# the Format classes).
#
# The purpose is to allow internal objects, like sheets and pages, to
# accumulate commands indicating the desired formatting, and later
# execute those commands, when the actual external GUI object is being
# constructed.
module Formatting

  # Returns the list of formatting commands that have been added to this object.
  def formatting
    @formatting ||= []
  end

  # Adds formatting command +command+ to the list.
  def add_formatting(command)
    formatting << command
  end

  # Base class for the formatting commands.
  class FormatCommand

    # A symbol identifying the type of command.
    attr_accessor :command

    # A CellRange object identifying the range of cells to which the
    # command should apply.
    attr_accessor :range

    # Initializes the command type and the range.
    # The default range of a single cell is supplied just in case
    # a particular command doesn't need a range; that way, any address
    # translation routines which attempt to translate the range of the
    # command will apply to the default range (ultimately making no difference)
    # rather than throwing an exception by attempting to call methods on nil.
    def initialize(command=nil, range=CellRange.new(1,1,1,1))
      @command = command
      @range = range
    end
  end # class FormatCommand

  # Commands that set the font size of text.
  # Command type symbol is +:textsize+.
  class TextSize < FormatCommand
    # Text size in points.
    attr_accessor :size
    # Returns a new TextSize formatting command, which will set the in-cell
    # text size to +size+ for all cells in range +range+.
    def initialize(range,size)
      super(:textsize, range)
      @size = size
    end
  end

  # Commands that set the text color.
  # Command type symbol is +:textcolor+.
  #
  # ===Colors
  # The colors are represented with symbols. The precise interpretation of
  # the symbols is determined by the GUI session implementation. However,
  # the GUI session should be able to properly interpret the following symbols:
  # * +:lightviolet+
  class TextColor < FormatCommand
    # Text color, as a symbol.
    attr_accessor :color
    # Returns a new TextColor formatting command, which will set the in-cell
    # text color to +color+ for all cells in range +range+.
    def initialize(range, color)
      super(:textcolor, range)
      @color = color
    end
  end

  # Commands that set text to bold.
  # Command type symbol is +:textbold+.
  class TextBold < FormatCommand
    # Boolean, with true indicating bold, and false indicating non-bold.
    attr_accessor :bold
    # Returns a new TextBold formatting command, which will set the in-cell
    # text to bold if +bold+ is not false/nil, for all cells in range +range+.
    def initialize(range, bold)
      super(:textbold, range)
      # convert bold parameter to boolean
      if bold then
        @bold = true
      else
        @bold = false
      end
    end
  end

  # Commands that set text to italic.
  # Command type symbol is +:textitalic+.
  class TextItalic < FormatCommand
    # Boolean, with true indicating italic, and false indicating non-italic.
    attr_accessor :italic
    # Returns a new TextItalic formatting command, which will set the in-cell
    # text to italic if +italic+ is not false/nil, for all cells in range +range+.
    def initialize(range, italic)
      super(:textitalic, range)
      # convert italic parameter to boolean
      if italic then
        @italic = true
      else
        @italic = false
      end
    end
  end

  # Sets the display format for the text in a cell. Currently, the only
  # defined value for the format attribute is :text (no symbols have been
  # employed for number, currency, time, etc. formats, as they are not
  # currently used by OTWorkplace).
  # Command type symbol is +:textformat+.
  class TextFormat < FormatCommand
    # Text format as a symbol (:text).
    attr_accessor :format
    # Returns a new TextFormat formatting command, which will set the cell
    # display format to +format+ for all cells in range +range+.
    def initialize(range, format)
      super(:textformat, range)
      @format = format
    end
  end

  # Commands that set the cell interior color.
  # Command type symbol is +:cellcolor+.
  #
  # ===Colors
  # The colors are represented with symbols. The precise interpretation of
  # the symbols is determined by the GUI session implementation. However,
  # the GUI session should be able to properly interpret the following symbols:
  # * +:red+
  # * +:gold+
  # * +:brightgreen+
  # * +:purple+
  # * +:paleyellow+
  # * +:yellow+
  # * +:brightcyan+
  # * +:lightcyan+
  # * +:lightgreen+
  # * +:magenta+
  class CellColor < FormatCommand
    # Cell interior color, as a symbol.
    attr_accessor :color
    # Returns a new CellColor formatting command, which will set the cell
    # interior color to +color+ for all cells in range +range+.
    def initialize(range, color)
      super(:cellcolor, range)
      @color = color
    end
  end

  # Commands that set the weight of a cell border.
  # Command type symbol is +:borderweight+.
  #
  # ===Edges
  # Edges are represented by symbols. The GUI session should be able to
  # properly interpret the following symbols:
  # * +:top+
  # * +:bottom+
  # * +:left+
  # * +:right+
  # * +nil+  to be interpreted as indicating all four edges.
  #
  # ===Weights
  # The weights are represented with symbols. The precise interpretation of
  # the symbols is determined by the GUI session implementation. However,
  # the GUI session should be able to properly interpret the following symbols:
  # * +:thin+
  # * +:medium+
  class BorderWeight < FormatCommand
    # The weight of the border, as a symbol.
    attr_accessor :weight
    # The cell edge being weighted, as a symbol.
    attr_accessor :edge
    # Returns a new BorderWeight formatting command, which will set the
    # border on the +edge+ cell edge to weight +weight+, for all cells in
    # range +range+.
    def initialize(range, weight, edge=nil)
      super(:borderweight, range)
      @weight = weight
      @edge = edge
    end
  end

  # Commands that set the style of a cell border.
  # Command type symbol is +:borderstyle+.
  #
  # ===Edges
  # Edges are represented by symbols. The GUI session should be able to
  # properly interpret the following symbols:
  # * +:top+
  # * +:bottom+
  # * +:left+
  # * +:right+
  # * +nil+  to be interpreted as indicating all four edges.
  #
  # ===Styles
  # The styles are represented with symbols. The precise interpretation of
  # the symbols is determined by the GUI session implementation. However,
  # the GUI session should be able to properly interpret the following symbols:
  # * +:double+  to be interpreted as indicating a double line border.
  # * +nil+      to be interpreted as indicating a single line border.
  class BorderStyle < FormatCommand
    # The style of the border, as a symbol.
    attr_accessor :style
    # The cell edge being styled, as a symbol.
    attr_accessor :edge
    # Returns a new BorderStyle formatting command, which will set the
    # border on the +edge+ cell edge to style +style+, for all cells in
    # range +range+.
    def initialize(range, style, edge=nil)
      super(:borderstyle, range)
      @style = style
      @edge = edge
    end
  end

  # Commands that set the width of columns.
  # Command type symbol is +:columnwidth+.
  class ColumnWidth < FormatCommand
    # The width of the column, as either a number or the symbol :autofit.
    attr_accessor :width
    # Returns a new ColumnWidth formatting command, which will set the
    # columns in range +range+ to a width according to the value of +width+.
    def initialize(range, width)
      super(:columnwidth, range)
      @width = width
    end
  end

  # Commands that set the horizontal alignment of text.
  # Command type symbol is +:horizontalalignment+.
  #
  # ===Directions
  # Directions are represented by symbols. The GUI session should be able to
  # properly interpret the following symbols for horizontal alignment:
  # * +:left+
  # * +:center+
  # * +:right+
  class HorizontalAlignment < FormatCommand
    # The text alignment direction, as a symbol.
    attr_accessor :direction
    # Returns a new HorizontalAlignment formatting command, which will set the
    # horizontal text alignment to direction +direction+ for all cells in
    # range +range+.
    def initialize(range, direction)
      super(:horizontalalignment, range)
      @direction = direction
    end
  end

  # Commands that set the vertical alignment of text.
  # Command type symbol is +:verticalalignment+.
  #
  # ===Directions
  # Directions are represented by symbols. The GUI session should be able to
  # properly interpret the following symbols for vertical alignment:
  # * +:top+
  # * +:center+
  # * +:bottom+
  class VerticalAlignment < FormatCommand
    # The text alignment direction, as a symbol.
    attr_accessor :direction
    # Returns a new VerticalAlignment formatting command, which will set the
    # vertical text alignment to direction +direction+ for all cells in
    # range +range+.
    def initialize(range, direction)
      super(:verticalalignment, range)
      @direction = direction
    end
  end

  # Commands that add autofilters to cells.
  # Command type symbol is +:autofilter+.
  class AutoFilter < FormatCommand
    # Returns a new AutoFilter formatting command, which will add an
    # autofilter to each cell in range +range+.
    def initialize(range)
      super(:autofilter, range)
    end
  end

  # Commands that insert PNG images from files into pages.
  # Command type symbol is +:imagepng+.
  class ImagePNG < FormatCommand
    # The filename for the file containing the PNG image to be inserted.
    attr_accessor :filename
    # Returns a new ImagePNG formatting command, which will insert the PNG
    # image stored in file +filename+ into a page in range +range+.
    # The details of how an inserted image will be displayed are to be
    # determined by the GUI session.
    def initialize(range, filename)
      super(:imagepng, range)
      @filename = filename
    end
  end

  # Commands that set the color of page tabs.
  # Command type symbol is +:tabcolor+.
  #
  # ===Colors
  # The colors are represented with symbols. The precise interpretation of
  # the symbols is determined by the GUI session implementation. However,
  # the GUI session should be able to properly interpret the following symbols:
  # * +:black+
  # * +:gold+
  class TabColor < FormatCommand
    # The color of the tab, as a symbol.
    attr_accessor :color
    # Returns a new TabColor formatting command, which will set the page tab
    # color to +color+ for the page that is active at the time the command
    # is executed.
    def initialize(color)
      super(:tabcolor, nil)
      @color = color
    end
  end

end # module Formatting
