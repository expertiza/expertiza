class ReviewStrategy
  attr_accessor :participants, :teams
  def initialize(participants, teams, review_num)
    @participants = participants
    @teams = teams
    @review_num = review_num
  end
end
