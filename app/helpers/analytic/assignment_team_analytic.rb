module AssignmentTeamAnalytic
  #return students in the participants
  def students
    students = Array.new
    self.participants.each do |participant|
      if participant.user.role_id == Role.student.id
        students << participant
      end
    end
    student
  end


  #====== general statistics ======#
  def num_participants
    self.participants.count
  end

  def num_students
    self.students.count
  end

  def num_reviews
    self.responses.count
  end

  #=== score related statistics ===#
  #return an array containing the score of all the reviews
  def review_scores
    scores = Array.new
    self.responses.each do |response|
      scores << response.get_average_score
    end
    scores
  end

  def average_review_score
    self.review_scores.inject(:+)/num_reviews
  end

  def max_review_score
    self.review_scores.max
  end

  def min_review_score
    self.review_scores.min
  end


end