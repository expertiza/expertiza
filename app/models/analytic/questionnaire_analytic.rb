require 'analytic/question_analytic'
module QuestionnaireAnalytic
  #return all possible questionnaire types
  def self.types
    type_list = Array.new
    self.find_each do |questionnaire|
      if !type_list.include?(questionnaire.type)
        type_list << questionnaire.type
      end
    end
    type_list
  end

  def num_questions
    self.questions.count
  end

  def questions_text_list
    question_list = Array.new
    self.questions.each do |questions|
      question_list << question.txt
    end
    question_list
  end

  def word_count_list
    word_count_list = Array.new
    self.questions.each do |question|
      word_count_list << question.word_count_list
    end
  end

  def total_word_count
    word_count_list.inject(:+)
  end

  def average_word_count
    total_word_count.to_f/num_questions
  end

  def character_count_list
    character_count_list = Array.new
    self.questions.each do |question|
      character_count_list << question.character_count
    end
  end

  def total_character_count
    character_count_list.inject(:+)
  end

  def average_character_count
    total_character_count/num_questions
  end

end
