class ReviewRoundStats
  attr_accessor :criteria

  def initialize(array_of_criterion)
    @criteria = array_of_criterion
  end

  def means
    @criteria.map(&:mean)
  end

  def medians
    @criteria.map(&:median)
  end

  def number_of_criteria
    @criteria.size
  end
end
