class AssignmentStats
  attr_accessor :review_round_stats, :name

  def initialize(array_stats, name)
    @review_round_stats = array_stats
    @name = name
  end

  def size
    @review_round_stats.size
  end
end
