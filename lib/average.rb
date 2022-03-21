module Average

  def calc_avg_score(reviews)
    # If a student has not taken an assignment or if they have not received any grade for the same,
    # assign it as nil(not returning anything). This helps in easier calculation of overall grade
    grades = 0
    # Check if they person has gotten any review for the assignment
    if reviews.count > 0
      reviews.each { |review| grades += review.average_score.to_i }
      return (grades * 1.0 / reviews.count).round
    end
  end
end
