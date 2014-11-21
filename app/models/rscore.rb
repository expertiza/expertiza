class Rscore
  attr_accessor :my_max
  attr_accessor :my_min,:my_avg,:my_type
  def initialize(max=0,min=0,avg=0,type=nil)
    @my_max=max
    @my_min=min
    @my_avg=avg
    @my_type=type
  end
end