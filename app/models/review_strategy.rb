class ReviewStrategy
  attr_accessor :participants, :teams

  def initialize(participants, teams, review_num)
    @participants = participants
    @teams = teams
    @review_num = review_num
  end
end

class StudentReviewStrategy < ReviewStrategy
  def reviews_per_team
    (@participants.size * @review_num * 1.0 / @teams.size).round
  end

  def reviews_needed
    @participants.size * @review_num
  end

  def reviews_per_student
    @review_num
  end
end

class TeamReviewStrategy < ReviewStrategy
  def reviews_per_team
    @review_num
  end

  def reviews_needed
    @teams.size * @review_num
  end

  def reviews_per_student
    (@teams.size * @review_num * 1.0 / @participants.size).round
  end
end
