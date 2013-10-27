require 'analytic/score_analytic'
module ResponseAnalytic
  def num_questions
    self.scores.count
  end

  #====== score =======#
  def average_score
    question_score_list.inject(:+)/num_questions
  end

  def max_question_score
    question_score_list.max
  end

  def min_question_score
    question_score_list.min
  end

  #====== word count ======#
  def total_word_count
    word_count_list.inject(:+)
  end

  def average_word_count
    total_word_count.to_f/num_questions
  end

  def max_word_count
    word_count_list.max
  end

  def min_word_count
    word_count_list.min
  end

  #====== character count ====#
  def total_character_count
    character_count_list.inject(:+)
  end

  def average_character_count
    total_character_count.to_f/num_questions
  end

  def max_character_count
    character_count_list.max
  end

  def min_character_count
    character_count_list.min
  end

  private
  #return an array of strings containing the word count of al the comments
  def word_count_list
    list = Array.new
    self.scores.each do |score|
      list << score.word_count
    end
    if (list.empty?)
      [0]
    else
      list
    end
  end

  def character_count_list
    list = Array.new
    self.scores.each do |score|
      list << score.character_count
    end
    if (list.empty?)
      [0]
    else
      list
    end
  end

  #return score for all of the questions in an array
  def question_score_list
    list = Array.new
    self.scores.each do |score|
      list << score.score
    end
    if (list.empty?)
      [0]
    else
      list
    end
  end

  #return an array of strings containing all of the comments
  def comments_text_list
    comments_list = Array.new
    self.scores.each do |score|
      comments_list << score.comments
    end
    comments_list
  end

end
