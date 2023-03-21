class Rscore
  attr_accessor :my_max, :my_min, :my_avg, :my_type
  # def initialize(max = 0.0, min = 0.0, avg = 0.0, type = nil)
  #   @my_max = max == -1 ? "N/A" : max
  #   @my_min = min == -1 ? "N/A" : min
  #   @my_avg = avg == -1 ? "N/A" : avg
  #   @my_type = type
  # end

  def initialize(my_score, type)
    @my_max = my_score[type][:scores][:max] == -1 ||  my_score[type][:scores][:max].nil? ? 'N/A' : my_score[type][:scores][:max]
    @my_min = my_score[type][:scores][:min] == -1 ||  my_score[type][:scores][:min].nil? ? 'N/A' : my_score[type][:scores][:min]
    @my_avg = my_score[type][:scores][:avg] == -1 ||  my_score[type][:scores][:avg].nil? ? 'N/A' : my_score[type][:scores][:avg]
    @my_type = type
  end
end
