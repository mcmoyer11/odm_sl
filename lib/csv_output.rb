# Author: Bruce Tesar

require_relative 'sheet'
require_relative 'otlearn/grammar_test_image'
require 'csv'

# Constructs a CSV (comma-separated value) representation of the data from
# a language learning simulation. The simulation object is passed as
# a parameter to the constructor, and an internal formatted result is
# automatically constructed. A separate method, #write_to_file, can be
# used to write the CSV formatted output to a file.
# Uses the CSV library.
class CSV_Output
  # Takes a language learning simulation as parameter _land_sim_, and
  # automatically constructs a CSV image of the results.
  def initialize(lang_sim)
    @lang_sim = lang_sim
    @page_image = Sheet.new
    format_results
  end
  
  # Write the CSV-formatted results to the file _destination_.
  # It writes the column headers as the first line.
  def write_to_file(destination)
    CSV.open(destination, "w", {:write_headers=>true}) do |csv|
      # Convert the page sheet to an array, and send each row of the array
      # to CSV.
      @page_image.to_a.each do |row|
        csv << row
      end
    end
  end
  
  def format_results
    # Put the language label in row 2, leaving row 1 as a header row.
    @page_image[2,1] = @lang_sim.grammar.label
    # Indicate if learning succeeded, by checking the last result in the
    # language simulation.
    @page_image[3,1] = "Learned: #{@lang_sim.results_list[-1].all_correct?}"
    # Write each simulation result to the output.
    @lang_sim.results_list.each do |entry|
      # Leave a blank line, and put the grammar test image of the entry.
      # TODO: each entry should contain its own appropriate image.
      next_row = @page_image.row_count+2
      grammar_test_image = OTLearn::GrammarTestImage.new(entry)
      @page_image.put_range[next_row,1] = grammar_test_image.sheet
    end
    headers_nil_to_blank
  end
  protected :format_results
  
  # Pad the first row so that any empty cells contain a blank (not nil).
  # The first row is treated as a header row by the NetBeans CSV editor,
  # and if an entry is nil, the CSV editor ignores the entire column,
  # truncating the display in the editor.
  def headers_nil_to_blank
    (1..@page_image.col_count).each do |col|
      @page_image[1,col]=" " unless @page_image[1,col]
    end
  end
  protected :headers_nil_to_blank
  
end # class CSV_Output
