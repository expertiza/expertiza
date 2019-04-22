class AssignmentStats
  attr_accessor :review_round_stats

  def initialize(array_stats)
    @review_round_stats = array_stats
  end

  def size
    @review_round_stats.size
  end
end