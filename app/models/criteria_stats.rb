class CriteriaStats
  attr_accessor :stats

  def initialize(stats)
    @stats = stats
  end

  def size
    @stats.size
  end
end
