


#Class created to have more informative output to the results_list during
#a learning simulation


class Winners_image
  
  def initialize(winners)
    @winners = winners
    @sheet = Sheet.new
    @last_row = 0
    format_list
  end

  def sheet
    @sheet
  end
  
  def format_list
    @winners.each do |w|
      @sheet[@last_row+1,1] = w.to_s
      @last_row+=1
    end
  end
  
  

  
end #class