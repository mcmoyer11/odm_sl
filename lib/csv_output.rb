# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require_relative 'sheet'
require_relative 'otlearn/rcd_bias_low'
require_relative 'rcd_image'
require 'csv'

class CSV_Output
  def initialize(lang_sim)
    @lang_sim = lang_sim
    @page_image = Sheet.new
    format_results
  end
  
  def format_results
    hyp = @lang_sim.hypothesis
    @page_image[1,1] = hyp.label
    @lang_sim.results_list.each do |entry|
#      range(ws,row,1,row,1).value = "#{entry.label}:"
#      row, col = learning_result_to_ws(ws, entry, row+1, 1)
      hyp = entry.hypothesis.dup
      rcd_result = hyp.update_grammar{|ercs| OTLearn::RcdFaithLow.new(ercs)}
      @result_image = RCD_image.new({:rcd=>rcd_result})
      next_cell = Cell.new(@page_image.row_count+1, 1)
      @page_image.put_range(next_cell, @result_image.sheet)
    end
    # pad the first row so that empty cells contain a blank
    # TODO: make this add an initial line with blanks (not nil) for cell values.
    # That way, the CSV editor will display all of the columns, and all column
    # headers will be blank.
    (1..@page_image.col_count).each do |col|
      @page_image.put_cell(Cell.new(1,col)," ") unless @page_image.get_cell(Cell.new(1,col))
    end
  end
  private :format_results
  
  def write_to_file
    CSV.open('temp/output.csv', "w", {:write_headers=>true}) do |csv|
      @page_image.to_a.each do |row|
        csv << row
      end
    end
  end
  
end # class CSV_Output
