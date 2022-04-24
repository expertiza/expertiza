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
