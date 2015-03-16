class Rscore
  attr_accessor :my_max,:my_min,:my_avg,:my_type
  def initialize(max=0.0,min=0.0,avg=0.0,type=nil)
    @my_max=max
    @my_min=min
    @my_avg=avg
    @my_type=type
  end
  def initialize(my_score,type)
    @my_max=my_score[type][:scores][:max]
    @my_min=my_score[type][:scores][:min]
    @my_avg=my_score[type][:scores][:avg]
    @my_type=type
  end
end