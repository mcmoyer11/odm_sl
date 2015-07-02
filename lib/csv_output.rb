# Author: Bruce Tesar

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
    # Put the language label in row 2, leaving row 1 as a header row.
    @page_image[2,1] = @lang_sim.hypothesis.label
    # Indicate if learning succeeded, by checking the last result in the
    # language simulation.
    @page_image[3,1] = "Learned: #{@lang_sim.results_list[-1].all_correct?}"
    # Write each simulation result to the output.
    @lang_sim.results_list.each do |entry|
      # Leave a blank line, and put the entry label in column 1.
      next_row = @page_image.row_count+2
      @page_image[next_row,1] = entry.label
      # Test result components are frozen, so dup before updating.
      hyp = entry.hypothesis.dup
      # Update grammar to contain the faith-low bias ranking.
      rcd_result = hyp.update_grammar{|ercs| OTLearn::RcdFaithLow.new(ercs)}
      # Build the image of the entry (support and lexicon), and write it
      # to the page starting in column 2.
      result_image = RCD_image.new({:rcd=>rcd_result})
      next_cell = Cell.new(@page_image.row_count+1, 2)
      @page_image.put_range(next_cell, result_image.sheet)
    end
    # Pad the first row so that any empty cells contain a blank (not nil).
    # The first row is treated as a header row by the NetBeans CSV editor,
    # and if an entry is nil, the CSV editor ignores the entire column,
    # truncating the display in the editor.
    (1..@page_image.col_count).each do |col|
      @page_image.put_cell(Cell.new(1,col)," ") unless @page_image.get_cell(Cell.new(1,col))
    end
  end
  private :format_results
  
  # Write the CSV-formatted results to the file _destination_.
  # It writes the column headers as the first line.
  def write_to_file(destination)
    CSV.open(destination, "w", {:write_headers=>true}) do |csv|
      # TODO: add an iterator #each_row to class Sheet.
      @page_image.to_a.each do |row|
        csv << row
      end
    end
  end
  
end # class CSV_Output
