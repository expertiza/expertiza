class VmQuestionResponseScoreCell

  def initialize(questionText, question_id, weight,question_max_score,seq)
    @questionText = questionText
    @weight = weight
    @question_id = question_id
    @question_seq = seq

    @question_max_score = question_max_score

    @score_row = Array.new
    @countofcomments = 0
  end

  def countofcomments
    @countofcomments
  end

  def question_seq
    @question_seq
  end
  def countofcomments=(newcount)
    @countofcomments = newcount
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

  def question_max_score
    question = Question.find(self.question_id)
    if question.type == "Checkbox"
      return 1
    end
    @question_max_score
  end

  def average_score_for_row
    row_average_score = 0.0
    @score_row.each do |score|
      if score.score_value.is_a? Numeric
        row_average_score += score.score_value.to_f
      end
    end
    row_average_score /= @score_row.length.to_f
    row_average_score.round(2)
  end

end