class ReviewRoundStats
  include Enumerable
  attr_accessor :criteria_stats

  def initialize(criteria_stats)
    @criteria_stats = criteria_stats
  end

  def size
    @criteria_stats.size
  end

  def each(&block)
    @criteria_stats.each(&block)
  end
end
