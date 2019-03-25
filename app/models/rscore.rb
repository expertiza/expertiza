class Rscore
  attr_accessor :my_max, :my_min, :my_avg, :my_type

  def initialize(my_score, type)
    @my_max = my_score[type][:scores][:max] == -1 ? "N/A" : my_score[type][:scores][:max]
    @my_min = my_score[type][:scores][:min] == -1 ? "N/A" : my_score[type][:scores][:min]
    @my_avg = my_score[type][:scores][:avg] == -1 ? "N/A" : my_score[type][:scores][:avg]
    @my_type = type
  end
end
