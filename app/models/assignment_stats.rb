class AssignmentStats
  attr_accessor :rounds, :name
  def initialize(assignment_id)
    # TODO actual implementation
    @rounds = [
      ReviewRoundStats.new(),
      ReviewRoundStats.new()
    ]
    @name = 'Final Project (and Design Document)'
  end
end
