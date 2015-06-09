# Author: Bruce Tesar
#
# The Excel interface for RUBOT.

 
require 'win32ole' # need this to use OLE automation
require 'dl' # Windows API access (for messagebox)
require_relative 'constraint'
require_relative 'candidate'
require_relative 'competition'
require_relative 'competition_list'
require_relative 'comparative_tableau'
require_relative 'skb_expansion'
require_relative 'ranking_diagram'
require_relative 'vt_page'
require_relative 'ct_image'
require_relative 'rcd_page'
require_relative 'rcd_image'
require_relative 'cell'

require 'REXML/syncenumerator' # Ruby 1.9 moved syncenumerator to REXML.

# A session for interacting with excel. Once an Excel_session object
# is created, it can connect to an already running instance of Excel
# via connect_to_excel(), or it can launch a new excel session via
# start_excel(). Other methods of the class provide RUBOT-specific
# ways of reading from and writing to Excel.
#
# Methods with names beginning with "put_" create one or more new
# worksheets, and fully determine the content of those worksheets.
# Methods with names ending with "_to_ws" add content to existing
# worksheets; the worksheet to be written to and the starting location
# to write to on the sheet are passed in as parameters.
class Excel_session
  # Excel Constants
  # Load built-in Excel constants (Xl*); for a list, see
  # http://msdn.microsoft.com/en-us/library/aa221100(office.11).aspx
  # The constants of the variety Xl* can be obtained from WIN32OLE.
  # const_load(<excel object>, Excel_session) obtains the
  # defined Excel constaints and makes them constants of the class Excel_session.
  # That way, they can be used in the methods of this class, which makes it
  # much easier to use the MSDN Reference Library for the Excel VBA calls.
  # Reference: http://msdn.microsoft.com/en-us/library/aa220733(office.11).aspx
  begin
    WIN32OLE.const_load(WIN32OLE.connect("excel.application"), Excel_session) # Load excel constants
  rescue WIN32OLERuntimeError # error exception thrown if Excel isn't running.
    # Create a temporary excel app, so that constants can be loaded from it.
    excel_temp = WIN32OLE.new("excel.application")
    WIN32OLE.const_load(excel_temp, Excel_session) # Load excel constants
    excel_temp.ole_free # Terminate the temporary excel app
  end
  
  #--
  # The color index constants aren't defined as colors in Excel, because they
  # actually point to positions in the default color palette, which can be
  # dynamically changed by the user. The color assignments given below
  # as constants reflect the Excel defaults: the colors that by default are
  # in the numbered positions in the color palette.
  # Color index constant usage: obj.colorindex = CONST
  BLACK = 1 #:nodoc:
  RED = 3 #:nodoc:
  BRIGHTGREEN = 4 #:nodoc:
  BLUE = 5 #:nodoc:
  PURPLE = 17 #:nodoc:
  PALEYELLOW = 19 #:nodoc:
  YELLOW = 27 #:nodoc:
  BRIGHTCYAN = 28 #:nodoc:
  LIGHTCYAN = 34 #:nodoc:
  LIGHTGREEN = 35 #:nodoc:
  MIDYELLOW = 36 #:nodoc:
  MAGENTA = 38 #:nodoc:
  GOLD = 44 #:nodoc:

  # Nothing "instance-ish" to initialize.
  def initialize
  end
  
  # Connects to a running Excel server.
  def connect_to_excel
    @excel = WIN32OLE.connect("excel.application") # connects to an already running Excel
  rescue WIN32OLERuntimeError # error exception thrown if Excel isn't running.
    puts "RuntimeError: Excel probably isn't running." # print an error message (in English) to Console
    display_ok_box("RuntimeError: Excel probably isn't running.")
    exit
  end
  
  # Starts a new excel session with a fresh workbook.
  def start_excel
    @excel = WIN32OLE.new("excel.application")
    add_output_workbook('New')
    @excel.visible=true
  end

  def start_excel_empty
    @excel = WIN32OLE.new("excel.application")
  end

  def get_excel
    @excel
  end

  def open_wb(wbname)
    wb = @excel.workbooks.open(wbname)
    return wb
  end

  # Display a simple pop-up window with an OK button and
  # the message _msg_.
  # This uses a standard Windows message window via the Windows API.
  def display_ok_box(msg)
    message = msg
    title = 'OTWorkplace'
    buttons = 0 # 0 indicates that an OK button should be displayed.
    user32 = DL.dlopen('user32')
    # The code below was obtained from posts on the Ruby forum (www.ruby-forum.com),
    # which attribute the 1.9 code to the Ruby development team.
    msgbox = DL::CFunc.new(user32['MessageBoxA'], DL::TYPE_LONG, 'MessageBox')
    r, rs = msgbox.call([0, message, title, buttons].pack('L!ppL!').unpack('L!*'))
    return r
  end

  def pages
    get_excel.sheets
  end

  def add_page(rel=:after, ref_page=get_active_ws)
    if rel==:before then
      rel_str = 'Before'
    elsif rel==:after then
      rel_str = 'After'
    else
      raise RuntimeError, "Excel_session.add_page(): first argument must be :before or :after but is #{rel}"
    end
    get_excel.sheets.add(rel_str=>ref_page)
  end
  
  def cell_value(cell, ws=@excel.activesheet)
    ws.cells(cell.row, cell.col).value
  end

  # Returns a list of the cells that are currently selected.
  # The list is an array of cell coordinates, each of which is an array
  # with a row index and a column index.
  def get_selected_cells
    selected_cells = @excel.selection.specialcells(XlCellTypeVisible)
    return range_address_to_cell_list(selected_cells.address)
  end

  #TODO: move the project name specific info to Rubot_controller.
  # Puts the provided project name in the given worksheet.
  # Convention: the project name goes in the first row first column cell.
  def put_project_name(pname, ws=@excel.activesheet)
    pn_cell = ws.cells(1,1)
    pn_cell.value = pname
    format_project_name(ws)
  end

  #TODO: move the status stamp specific info to Rubot_controller.
  # Adds the given status stamp to the given worksheet.
  # Convention: the status stamp goes in the first row second column cell.
  def put_status_stamp(status, ws=@excel.activesheet)
    ss_cell = ws.cells(1,2)
    ss_cell.value = status
    format_status_stamp(ws)
  end

  # Applies standard formatting to the project name cell of worksheet +ws+.
  def format_project_name(ws=@excel.activesheet)
    pn_cell = ws.cells(1,1)
    pn_cell.font.bold = true
  end

  # Applies standard formatting to the status stamp cell of worksheet +ws+.
  def format_status_stamp(ws=@excel.activesheet)
    ss_cell = ws.cells(1,2)
    ss_cell.font.colorindex = 18
    ss_cell.font.italic = true
    ss_cell.font.bold = true
    ss_cell.font.size = 9
    ss_cell.horizontalAlignment = XlCenter
  end

  def put_learning_results(lang_sim)
    @excel.screenUpdating=false # turn off updating while writing to a worksheet
    hyp = lang_sim.hypothesis
    ws = @excel.sheets.add('After'=>@excel.activesheet)
    ws.name = name_sheet("Learn." + hyp.label)
    range(ws,1,1,1,1).value = hyp.label
    row = 1; col = 1
    #
    lang_sim.results_list.each do |entry|
      row += 3
      range(ws,row,1,row,5).merge
      range(ws,row,1,row,1).value = "#{entry.label}:"
      row, col = learning_result_to_ws(ws, entry, row+1, 1)
    end
    #
  ensure # make sure screen updating is turned back on, even if an exception is raised.
    @excel.screenUpdating=true    
  end
  
  def learning_result_to_ws(ws, gram_test_result, row_first, col_first)
    # Test result components are frozen, so dup before updating.
    hyp = gram_test_result.hypothesis.dup
    rcd_result = hyp.update_grammar{|ercs| OTLearn::RcdFaithLow.new(ercs)}
    # Add the unranked constraints as a "final stratum" to the hierarchy.
    hier_with_unranked = Hierarchy.new
    hier_with_unranked.concat(rcd_result.hierarchy)
    hier_with_unranked << rcd_result.unranked unless rcd_result.unranked.empty?
    sorted_cons = hier_with_unranked.flatten
    # sort the ercs with respect to the RCD constraint hierarchy
    sorted_ercs, ercs_by_stratum, explained_ercs = RCD_image.sort_rcd_results(rcd_result)
    # write the main CT to the new worksheet
    wl_pairs_to_ws(ws,sorted_cons,sorted_ercs,row_first,col_first)

    # Set some table index values
    pre_con_columns = 4
    col_count = pre_con_columns + sorted_cons.size
    pre_erc_rows = 1
    last_ex_row = pre_erc_rows + explained_ercs.size # row of last explained erc
    row_count = last_ex_row + rcd_result.unex_ercs.size
    
    # put vertical lines between the strata
    vl_col_count = pre_con_columns
    hier_with_unranked.each do |stratum|
      vl_col_count += stratum.size
      vl_row_last = row_first-1+row_count
      vl_col_last = col_first-1+vl_col_count
      range(ws,row_first,vl_col_last,vl_row_last,vl_col_last).borders(XlEdgeRight).weight =
        XlMedium # vertical line between strata
    end
    # put horizontal lines between the "stratified" clusters of ercs
    hl_row_count = pre_erc_rows
    ercs_by_stratum.each do |ercs|
      hl_row_count += ercs.size
      hl_row_last = row_first-1+hl_row_count
      hl_col_last = col_first-1+vl_col_count
      range(ws,hl_row_last,col_first,hl_row_last,hl_col_last).borders(XlEdgeBottom).weight =
        XlMedium
    end
    # Flag any unexplained ercs with color
    range(ws,row_first+last_ex_row,1,row_first-1+row_count,1).interior.colorindex = RED unless row_count == last_ex_row
    # Extra formatting if the data were inconsistent
    range(ws,row_first+row_count,1,row_first+row_count,1).value = "FAIL!" unless rcd_result.consistent?

    # Put the lexicon to the worksheet
    first_lex_row = row_first-1 + row_count + 2
    lex = hyp.grammar.lexicon
    r_row = first_lex_row-1
    r_row, r_col = morphs_to_ws(ws, lex.get_prefixes, r_row+1, col_first) unless lex.get_prefixes.empty?
    r_row, r_col = morphs_to_ws(ws, lex.get_roots, r_row+1, col_first)
    r_row, r_col = morphs_to_ws(ws, lex.get_suffixes, r_row+1, col_first) unless lex.get_suffixes.empty?
    
    test_row = r_row + 2
    range(ws,test_row,col_first,test_row,col_first+2).merge
    range(ws,test_row,col_first,test_row,col_first).value = "Learned: #{gram_test_result.all_correct?}"
    return test_row, col_first-1+col_count
  end
  
  # Puts a set of morpheme lexical entries into a single excel row.
  def morphs_to_ws(ws, morphs, row_first, col_first)
    row = row_first
    col = col_first - 3
    morphs.each do |morph|
      col += 3
      range(ws,row,col,row,col).value = morph.label.to_s
      range(ws,row,col+1,row,col+1).value = morph.uf.to_s      
    end
    return row_first, col+1
  end
  
  # Creates a new workbook, deletes any extra worksheets, renames
  # the remaining worksheet to the parameter, and returns the workbook.
  # Normally, this method should only be called by other methods in class Excel.
  def add_output_workbook ws_name
    output_wb = @excel.workbooks.add()
    sheets = @excel.sheets
    # obtain array of sheet names (@excel.sheets doesn't have methods like #first).
    sheet_names = []
    sheets.each{|s| sheet_names << s.name}
    # Keep the first sheet, delete any others.
    old_name = sheet_names.first
    sheets.each {|s| s.delete unless s.name==old_name}
    #output_wb.worksheets("Sheet2").delete
    #output_wb.worksheets("Sheet3").delete
    # Get the remaining worksheet, and rename it.
    ws = output_wb.worksheets(old_name)
    ws.name = ws_name
    return output_wb
  end

  def put_page(page, ref_ws=get_excel.activesheet, side=:after)
    @excel.screenUpdating=false # turn off while modifying worksheets
    ws = add_page(side, ref_ws)
    ws.name = name_sheet(page.page_name)
    sheet = page.sheet
    # Numberformat formatting must be applied *before* writing the values to
    # the sheet, or the language labels won't be formatted correctly.
    number_formatting, other_formatting =
      page.formatting.partition {|cmd| cmd.command==:textformat}
    number_formatting.each {|cmd| apply_format_command(cmd, ws)}
    # Calculate the sheet range, and write the sheet to the excel worksheet.
    sheetrange = CellRange.new(1,1,sheet.row_count,sheet.col_count)
    sr = sheetrange
    range(ws,sr.row_first,sr.col_first,sr.row_last,sr.col_last).value = sheet.to_a
    #
    other_formatting.each {|cmd| apply_format_command(cmd, ws)}
  ensure # make sure screen updating is turned back on, even if an exception is raised.
    @excel.screenUpdating=true
  end

  def apply_format_command(cmd, ws)
    r = cmd.range
    if r.nil? then
      erange = ws.cells # all cells in the worksheet
    else
      erange = range(ws,r.row_first,r.col_first,r.row_last,r.col_last)
    end

    case cmd.command
    when :textformat
      eformat = "@" if cmd.format==:text
      erange.numberformat = eformat

    when :textbold
      erange.font.bold = cmd.bold

    when :textitalic
      erange.font.italic = cmd.italic

    when :textcolor
      erange.font.colorindex = excel_color(cmd.color)

    when :textsize
      erange.font.size = cmd.size

    when :cellcolor
      erange.interior.colorindex = excel_color(cmd.color)

    when :borderweight
      if cmd.edge.nil? then
        erange.borders.weight = excel_weight(cmd.weight)
      else
        erange.borders(excel_edge(cmd.edge)).weight = excel_weight(cmd.weight)
      end

    when :borderstyle
      if cmd.edge.nil? then
        erange.borders.linestyle = excel_style(cmd.style)
      else
        erange.borders(excel_edge(cmd.edge)).linestyle = excel_style(cmd.style)
      end

    when :columnwidth
      if cmd.width==:autofit then
        erange.entirecolumn.autofit
      else
        erange.columns.columnwidth = cmd.width
      end

    when :horizontalalignment
      erange.horizontalAlignment = excel_direction(cmd.direction)
      
    when :verticalalignment
      erange.verticalAlignment = excel_direction(cmd.direction)

    when :autofilter
      erange.autofilter

    when :imagepng
      put_png_comment(cmd.filename, erange)

    when :tabcolor
      ws.tab.colorindex = excel_color(cmd.color)
    else
      puts "Formatting Command not recognized."
    end
  end

  def excel_edge(edge)
    case edge
    when :top    then XlEdgeTop
    when :bottom then XlEdgeBottom
    when :left   then XlEdgeLeft
    when :right  then XlEdgeRight
    else              nil
    end
  end

  def excel_weight(weight)
    case weight
    when :thin   then XlThin
    when :medium then XlMedium
    else              nil
    end
  end

  def excel_style(style)
    case style
    when :double then XlDouble
    else              nil
    end
  end

  def excel_direction(direction)
    case direction
    when :left   then XlLeft
    when :center then XlCenter
    when :right  then XlRight
    when :top    then XlTop
    when :bottom then XlBottom
    else              nil
    end
  end

  def excel_color(color)
    case color
    when :black       then  1
    when :red         then  3
    when :brightgreen then  4
    when :blue        then  5
    when :purple      then 17
    when :lightviolet then 18
    when :paleyellow  then 19
    when :yellow      then 27
    when :brightcyan  then 28
    when :lightcyan   then 34
    when :lightgreen  then 35
    when :midyellow   then 36
    when :magenta     then 38
    when :gold        then 44
    else                   nil
    end
  end

  # Format a comparative tableau, and write it to the specified section of the worksheet.
  def wl_pairs_to_ws(ws, sorted_cons, sorted_ercs, row_first, col_first)
    # first row contains the column headers
    sheet_image = [] << (row_image = [])
    row_image.concat(["ERC\#", "Input", "Winner", "Loser"])
    pre_con_columns = 4
    row_image.concat(sorted_cons.map{|con| con.to_s})
    # add the erc rows to the sheet image
    sorted_ercs.each do |erc|
      sheet_image << (row_image = []) # elements of the eventual output row
      row_image << erc.label
      if erc.respond_to?(:winner) then # pair contains a winner and a loser
        row_image << erc.winner.input.to_s << erc.winner.merged_outputs_to_s
        row_image <<  erc.loser.output.to_s
      else
        3.times{row_image << nil} # base ercs don't have winner or loser
      end
      add_prefs_to_row(erc, sorted_cons, row_image)
    end
    # write the sheet_image array to the worksheet
    row_last = row_first + sheet_image.size - 1
    col_last = col_first + pre_con_columns + sorted_cons.size - 1
    range(ws,row_first,col_first,row_last,col_last).value = sheet_image
    tableau_formatting(ws,row_first,col_first,row_last,col_last,pre_con_columns)
    return row_last, col_last
  end

  # Draws standard comparative tableau formatting
  def tableau_formatting(ws,row_first,col_first,row_last,col_last,pre_con_columns)
    # autosize the columns
    range(ws,row_first,col_first,row_last,col_last).entirecolumn.autofit
    # bold the headings
    range(ws,row_first,col_first,row_first,col_last).font.bold = true
    # format the evaluation cells
    first_con = col_first + pre_con_columns # first column for a constraint
    range(ws,row_first+1,first_con,row_last,col_last).horizontalAlignment = XlCenter # center justification
    # Set the borders
    range(ws,row_first,col_first,row_last,col_last).borders.weight = XlThin  # basic grid
    range(ws,row_first,col_first,row_first,col_last).borders(XlEdgeTop).weight = XlMedium # top of table
    range(ws,row_last,col_first,row_last,col_last).borders(XlEdgeBottom).weight = XlMedium # bottom of table
    range(ws,row_first,col_first,row_first,col_last).borders(XlEdgeBottom).linestyle = XlDouble # top double line
    range(ws,row_first,first_con-1,row_last,first_con-1).borders(XlEdgeRight).linestyle = XlDouble # vertical double line
    return ws    
  end
  
  def add_prefs_to_row(ct_row, sorted_cons, row_image)
    sorted_cons.each do |con|
      if ct_row.l?(con)
        row_image << "L"
      elsif ct_row.w?(con)
        row_image << "W"
      else
        row_image << nil  # Leave 'e' cells blank, for readability
      end
    end
    row_image
  end

  # Returns an excel range object from the begin cell to the end cell,
  # relative to the parameter base, which can be a worksheet or a range.
  def range(base, row_begin, col_begin, row_end, col_end)
    base.range(range_to_s(row_begin, col_begin, row_end, col_end))
  end

  # Converts an integer column designation to the equivalent letter string
  # for Excel: 1 -> 'A', 26 -> 'Z', 27 -> 'AA', 1424 -> 'BBT', etc.
  def col_to_letter(col)
    raise "col_to_letter(): Cannot have a nonpositive column index." if col<1
    digit_array = []
    residue = col
    until residue==0 do
      mod = residue % 26
      mod = 26 if mod==0   # scale is 1..26, not 0..25
      letter = (mod + 'A'.ord - 1).chr
      digit_array.unshift(letter)
      residue = (residue-1).div(26) # don't add a higher digit until above 26
    end
    digit_array.join
  end

  # Converts a letter string column designation to the equivalent integer.
  # 'A' -> 1, 'Z' -> 26, 'AA' -> 27, 'BBT' -> 1424, etc.
  def letter_to_col(cletter)
    raise "letter_to_col(): string must be letters only." unless cletter=~/^[a-zA-Z]+$/
    codes = cletter.upcase.codepoints.to_a   # array of numeric character codes
    codes.inject(0){|sum,code| 26*sum + (code - 'A'.ord + 1)}
  end

  # Converts row/column integer designations of a range into Excel letter/number
  # format.
  # ==Examples
  # range_to_s(1,2,3,4) -> "B1:D3"
  def range_to_s(row_first, col_first, row_last, col_last)
    "#{col_to_letter(col_first)}#{row_first}:#{col_to_letter(col_last)}#{row_last}"
  end

  # Converts an Excel range string into a list of cells, with each cell
  # an object responding to #row and #col.
  # * +range_addr+ - string listing a range (returned by Excel's Range.address)
  # ==Examples
  # range_address_to_cell_list('$B$6,$AB$15,$CA$1') -> [cell1, cell2, cell3]
  # where cell1.row=6, cell1.col=2, cell2.row=15, cell2.col=28,
  # cell3.row=1, cell3.col=79.
  def range_address_to_cell_list(range_addr)
    addr_string_list = range_addr.scan(/\$[A-Z]+\$[0-9]+/)
    coord_list = addr_string_list.map{|a_str| a_str=~/([A-Z]+).([0-9]+)/; [$2,$1]}
    coord_list.map{|c| Cell.new(c[0].to_i, letter_to_col(c[1]))}
  end

  # Returns the size of the PNG image stored in the file of name _fname_,
  # as an array [width, height] giving the values in points.
  def png_size(fname)
    # Read the first 24 bytes of the image file into a string.
    prefix = nil
    File.open(fname, mode: "rb"){|fh| prefix = fh.read(24)}
    # A PNG file has bytes 1-3 with the value "PNG".
    raise "file is not PNG" unless prefix[1..3] == "PNG"
    # Read the picture size (in points) from bytes 16-24.
    return prefix[16..24].unpack('NN')
  end

  # Adds a pop-up comment to _cell_, and fills it with the PNG image
  # stored in file _fname_.
  def put_png_comment(fname, cell)
    # get the dimensions (in points) of the image
    width, height = png_size(fname)
    cell.clearcomments
    cbox = cell.addcomment # returns a reference to the comment box
    cbox.shape.fill.userpicture(fname) # fill with the picture
    cbox.text " " # to blank out the inserted username.
    # resize the comment box shape to 50% of the original picture size
    cbox.shape.width = width/2
    cbox.shape.height = height/2
    cell.comment.visible = true    # make the diagram automatically visible
  end

  # Returns an array of the names of the sheets in the active workbook.
  def sheet_names_active_wb
    sheet_names = []
    get_excel.sheets.each{|sheet| sheet_names << sheet.name}
    return sheet_names
  end

  def get_active_ws
    get_excel.activesheet
  end

  # Returns a reference to the worksheet with name +sheet_name+.
  # Returns nil if no such worksheet exists in the active workbook.
  def get_sheet_by_name(sheet_name)
    sheet_names = sheet_names_active_wb
    return nil unless sheet_names.include?(sheet_name)
    return get_excel.worksheets(sheet_name)
  end

  def name_sheet(orig_name)
    sheet_names = sheet_names_active_wb
    activesheet_name = get_excel.activeworkbook.activesheet.name
    sheet_names = sheet_names.delete_if{|name| name==activesheet_name}
    sheet_matches = sheet_names.find_all{|name| name.upcase =~ /^#{orig_name.upcase}(\{|$)/}
    return orig_name if sheet_matches.empty?
    indices = sheet_matches.map{|val| val=~/\{(\d+)/ ? $1.to_i : 1}
    new_index = indices.max + 1
    return orig_name + "\{#{new_index.to_s}\}"
  end

  def put_worksheet_name(name, ws=nil)
    ws = get_excel.activeworkbook.activesheet if ws.nil?
    ws.name = name_sheet(name)
  end

  def get_usedrange_value(ws=get_excel.activesheet)
    return ws.usedrange.value
  end

  def color_cell(cell, color, ws=get_excel.activesheet)
    ws.cells(cell.row,cell.col).interior.colorindex = excel_color(color)
  end

  def color_tab(color, ws=get_excel.activesheet)
    ws.tab.colorindex = excel_color(color)
  end

end # class Excel_session
