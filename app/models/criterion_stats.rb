class CriterionStats
  attr_accessor :mean, :median

  def initialize(mean, median)
    @mean = mean
    @median = median
  end

  def metrics
    %w[Mean Median]
  end
end
