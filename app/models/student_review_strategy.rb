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
