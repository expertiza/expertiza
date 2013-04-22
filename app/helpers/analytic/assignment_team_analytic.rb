require 'helpers/analytic/response_analytic'
module AssignmentTeamAnalytic
  #======= general ==========#
  def num_participants
    self.participants.count
  end

  def num_students
    self.students.count
  end

  def num_reviews
    self.responses.count
  end

  #========== score ========#
  #return an array containing the score of all the reviews
  def review_scores_list
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
    self.review_scores_list.max
  end

  def min_review_score
    self.review_scores_list.min
  end

  #======= word count =======#
  def review_word_count_list
    word_count_list = Array.new
    self.responses.each do |response|
      word_count_list << response.total_word_count
    end
    word_count_list
  end

  def total_review_word_count
    review_word_count_list.inject(:+)
  end

  def max_review_word_count
    review_word_count_list.max
  end

  def min_review_word_count
    review_word_count_list.min
  end

  def average_review_word_count
    total_review_word_count.to_f/num_reviews
  end
  
  #===== character count ====#
  def review_character_count_list
    character_count_list = Array.new
    self.responses.each do |response|
      character_count_list << response.total_character_count
    end
    character_count_list
  end

  def total_review_character_count
    review_character_count_list.inject(:+)
  end

  def max_review_character_count
    review_character_count_list.max
  end

  def min_review_character_count
    review_character_count_list.min
  end

  def average_review_character_count
    total_review_character_count.to_f/num_reviews
  end

  private
  #return students in the participants
  def student_list
    students = Array.new
    self.participants.each do |participant|
      if participant.user.role_id == Role.student.id
        students << participant
      end
    end
    students
  end

end