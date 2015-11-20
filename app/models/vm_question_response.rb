class VmQuestionResponse

  def initialize()
      @listofrows = []

  end

  def addQuestions(questions)
    questions.each do |question|
      row = VmQuestionResponse_Row.new(question.txt, question.id, question.weight)
      @listofrows << row
    end
    end

  def listofrows
    @listofrows

  end

  def  addAnswer(answer)
    @listofrows.each do |row|
      if row.question_id == answer.question_id
        row.score_row.push(answer.answer)
      end
    end
  end
end

class VmQuestionResponse_Row

  def initialize(questionText, question_id, weight)
    @questionText = questionText
    @question_id = question_id
    @weight = weight
    @score_row = Array.new
  end

  def questionText
    @questionText
  end

  def question_id
         @question_id
  end

  def score_row
    @score_row
  end

  def weight
    @weight
  end

end