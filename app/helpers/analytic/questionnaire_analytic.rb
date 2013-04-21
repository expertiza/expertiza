module QuestionnaireAnalytic
  #return all possible questionnaire types
  def self.types
    type_list = Array.new
    self.all.each do |questionnaire|
      if !type_list.include?(questionnaire.type)
        type_list << questionnaire.type
      end
    end
    type_list
  end

  def word_count
    sum = 0
    self.questions.each do |question|
      sum += question.word_count
    end
    sum
  end

  def average_word_count
    self.word_count.to_f/self.questions.count
  end

  def character_count
    sum = 0
    self.questions.each do |question|
      sum += question.character_count
    end
  end

  def average_character_count
    self.character_count/self.questions.count
  end

end