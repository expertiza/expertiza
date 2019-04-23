class AssignmentStats
  attr_accessor :rounds, :name

  def initialize(assignment_id)
    criteria_array1 = [
      CriterionStats.new(76, 3),
      CriterionStats.new(84, 3.5),
      CriterionStats.new(54, 2.5),
      CriterionStats.new(92, 3.5),
      CriterionStats.new(64, 3)
    ]
    criteria_array2 = [
      CriterionStats.new(64, 3),
      CriterionStats.new(92, 3.5),
      CriterionStats.new(78, 3),
      CriterionStats.new(54, 2.5)
    ]
    @rounds = [ReviewRoundStats.new(criteria_array1),
               ReviewRoundStats.new(criteria_array2)]
    @name = Assignment.find(assignment_id).name
  end

  def number_of_rounds
    @rounds.size
  end

  def metrics
    @rounds[0].metrics
  end
end
