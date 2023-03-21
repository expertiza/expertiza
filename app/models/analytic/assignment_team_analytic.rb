# require 'analytic/response_analytic'
module AssignmentTeamAnalytic
  #======= general ==========#
  def num_participants
    participants.count
  end

  def num_reviews
    responses.count
  end

  #========== score ========#
  def average_review_score
    if num_reviews == 0
      0
    else
      review_scores.inject(:+).to_f / num_reviews
    end
  end

  def max_review_score
    review_scores.max
  end

  def min_review_score
    review_scores.min
  end

  #======= word count =======#
  def total_review_word_count
    review_word_counts.inject(:+)
  end

  def average_review_word_count
    if num_reviews == 0
      0
    else
      total_review_word_count.to_f / num_reviews
    end
  end

  def max_review_word_count
    review_word_counts.max
  end

  def min_review_word_count
    review_word_counts.min
  end

  #===== character count ====#
  def total_review_character_count
    review_character_counts.inject(:+)
  end

  def average_review_character_count
    if num_reviews == 0
      0
    else
      total_review_character_count.to_f / num_reviews
    end
  end

  def max_review_character_count
    review_character_counts.max
  end

  def min_review_character_count
    review_character_counts.min
  end

  def review_character_counts
    list = []
    responses.each do |response|
      list << response.total_character_count
    end
    if list.empty?
      [0]
    else
      list
    end
  end

  # return an array containing the score of all the reviews
  def review_scores
    list = []
    responses.each do |response|
      list << response.average_score
    end
    if list.empty?
      [0]
    else
      list
    end
  end

  def review_word_counts
    list = []
    responses.each do |response|
      list << response.total_word_count
    end
    if list.empty?
      [0]
    else
      list
    end
  end
end
