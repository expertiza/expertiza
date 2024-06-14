require 'analytic/question_analytic'
module QuestionnaireAnalytic
  # return all possible question types
  def types
    type_list = []
    questions.each do |question|
      type_list << question.type unless type_list.include?(question.type)
    end
    type_list
  end

  def num_questions
    questions.count
  end

  def questions_text_list
    question_list = []
    questions.each do |question|
      question_list << question.txt
    end
    if question_list.empty?
      [0]
    else
      question_list
    end
  end

  def word_count_list
    word_count_list = []
    questions.each do |question|
      word_count_list << question.word_count
    end
    if word_count_list.empty?
      [0]
    else
      word_count_list
    end
  end

  def total_word_count
    word_count_list.inject(:+)
  end

  def average_word_count
    return total_word_count.to_f / num_questions unless num_questions == 0

    0
  end

  def character_count_list
    character_count_list = []
    questions.each do |question|
      character_count_list << question.character_count
    end
    if character_count_list.empty?
      [0]
    else
      character_count_list
    end
  end

  def total_character_count
    character_count_list.inject(:+)
  end

  def average_character_count
    return total_character_count.to_f / num_questions unless num_questions == 0

    0
  end
end
