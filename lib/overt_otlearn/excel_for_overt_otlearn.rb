# Author: Crystal Akers
#
# This file contains revisions to the Excel interface for RUBOT for use in
# learning multiple simulataneous language hypotheses.

require_relative '../../lib/otlearn'
require_relative '../../lib/overt_otlearn/language_hypothesis'
require_relative '../../lib/overt_otlearn/overt_language_learning'
require_relative '../../lib/rubot'
require 'excel'

module Overt_OTLearn

# A session for interacting with excel, specifically for the overt_otlearn simulations.

  class Excel_session_for_overt_otlearn < Excel_session
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
      WIN32OLE.const_load(WIN32OLE.connect("excel.application"), Excel_session_for_overt_otlearn) # Load excel constants
    rescue WIN32OLERuntimeError # error exception thrown if Excel isn't running.
      # Create a temporary excel app, so that constants can be loaded from it.
      excel_temp = WIN32OLE.new("excel.application")
      WIN32OLE.const_load(excel_temp, Excel_session_for_overt_otlearn) # Load excel constants
      excel_temp.ole_free # Terminate the temporary excel app
    end

    #--
    # The color index constants aren't defined as colors in Excel, because they
    # actually point to positions in the default color palette, which can be
    # dynamically changed by the user. The color assignments given below
    # as constants reflect the Excel defaults: the colors that by default are
    # in the numbered positions in the color palette.
    # Color index constant usage: obj.colorindex = CONST
    RED = 3 #:nodoc:
    BRIGHTGREEN = 4 #:nodoc:
    BLUE = 5 #:nodoc:
    PALEYELLOW = 19 #:nodoc:
    LIGHTGREEN = 35 #:nodoc:
    MIDYELLOW = 36 #:nodoc:
    MAGENTA = 38 #:nodoc:

    def initialize
      super
    end

    def put_learning_results(hyp, success)
      @excel.screenUpdating=false # turn off updating while writing to a worksheet
      ws = @excel.sheets.add('After'=>@excel.activesheet)
      if success == true then
        if hyp.results_list.last.all_correct? then
          ws.name = name_sheet(hyp.label + hyp.lang_hyp_label)
        else
          ws.name = name_sheet("(" + hyp.label + hyp.lang_hyp_label + ")")
        end
      else
        ws.name = name_sheet("(" + hyp.lang_hyp_label+ ")")
      end
      range(ws,1,1,1,1).value = hyp.label
      row = 1; col = 1
      #
      row +=2
      range(ws,2,1,2,3).merge
      range(ws,2,1,2,1).value = "Commitments"
      hyp.commitments.each  do |c_pair|
        row += 1
        range(ws, row, 1, row, 1). value = "#{c_pair[0].to_s}"
        range(ws, row, 2, row, 2).value = "#{c_pair[1].to_s}"
      end
      row+= 2
      range(ws,row, 1, row, 10).merge
      range(ws, row, 1, row, 1). value = "#{hyp.grammar.hierarchy.to_s}"
      hyp.results_list.each do |entry|
        row += 3
        range(ws,row,1,row,5).merge
        range(ws,row,1,row,1).value = "#{entry.label}:"
        row, col = learning_result_to_ws(ws, entry, row+1, 1)
      end
      #
    ensure # make sure screen updating is turned back on, even if an exception is raised.
      @excel.screenUpdating=true
    end

    def put_learning_results_of_sim(lang_sim)
      @excel.screenUpdating=false # turn off updating while writing to a worksheet
      ws = @excel.activesheet
      ws.name = name_sheet("Sim Results")
      row = 1; col = 1
      range(ws,1,1,1,1).value = "Results of Language Learning Simulation"
      lang_sim.results_list.each do |entry|
        row += 2
        range(ws,row,1,row,8).merge
        range(ws, row, 1, row, 1).value = entry
      end
      #
    ensure # make sure screen updating is turned back on, even if an exception is raised.
      @excel.screenUpdating=true
    end

    def put_typ_results_to_ws(overt_forms_list, overt_forms_set_label, learned_lgs, failed_consis_lgs, discards, row_first)
      ws = @excel.activesheet
      # first row contains a header for overt forms set
      sheet_image = [] << (row_image = [])
      row_image << overt_forms_set_label
      until overt_forms_list.empty? do
        sheet_image << (row_image = [])
        4.times do
          row_image << overt_forms_list.shift
        end
      end
      # second row contains the column headers
      sheet_image << (row_image = []) # elements of the eventual output row
      row_image.concat(["Learned Lgs", "Fail - Consis.", "Fail - Inconsis."])
      # Create the entries for the Learned Lgs column
      learned_col = []
      learned_lgs.each do |hyp|
        summary = String.new
        summary << hyp.lang_hyp_label << "; " << hyp.erc_list.size.to_s
        learned_col << summary
      end
      # Create entries for the Fail-Consist. lgs column
      failed_consis_col = []
      failed_consis_lgs.each do |hyp|
        summary = String.new
        summary << hyp.lang_hyp_label << "; " << hyp.erc_list.size.to_s
        failed_consis_col << summary
      end
      # Create entries for the Discard column
      discard_col = []
      discards.each do |hyp|
        summary = String.new
        summary << hyp.lang_hyp_label << "; " << hyp.erc_list.size.to_s
        discard_col << summary
      end
      # Create row images.
      max_rows = learned_lgs.size
      if failed_consis_lgs.size > max_rows then
        max_rows = failed_consis_lgs.size
      elsif discards.size > max_rows then
        max_rows = discards.size
      end
      curr_row = 0
      until curr_row == max_rows do
        sheet_image << (row_image = []) # elements of the eventual output row
        col1 = learned_col[curr_row]
        col2 = failed_consis_col[curr_row]
        col3 = discard_col[curr_row]
        row_image << col1 << col2 << col3
        curr_row +=1
      end
      # write the sheet_image array to the worksheet
      row_last = row_first + sheet_image.size - 1
      range(ws,row_first,1,row_last,4).value = sheet_image
      # autosize the columns
      range(ws,row_first,1,row_last,4).entirecolumn.autofit
      #
      return row_last +=2
      #
    end


    # Saves the active workbook as the given filename, then closes that workbook. Leaves
    # a new output workbook open in the current Excel session.
    def close(filename)
      wb = @excel.activeworkbook
      wb.saveas(filename)
      wb.close
      add_output_workbook('New')
    end

  end #class Excel_for_overt_otlearn
end #module Overt_OTLearn