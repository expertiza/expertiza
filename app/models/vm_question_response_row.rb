# represents each row of a heatgrid-table, which is represented by the vm_question_response class.
class VmQuestionResponseRow
  def initialize(questionText, question_id, weight, question_max_score, seq)
    @questionText = questionText
    @weight = weight

    @question_id = question_id
    @question_seq = seq

    @question_max_score = question_max_score

    @score_row = []

    @countofcomments = 0
  end

  attr_reader :countofcomments

  attr_reader :question_seq

  attr_writer :countofcomments

  attr_reader :questionText

  attr_reader :question_id

  attr_reader :score_row

  attr_reader :weight

  # the question max score is the max score of the questionnaire, except if the question is a true/false, in which case
  # the max score is one.
  def question_max_score
    question = Question.find(self.question_id)
    if question.type == "Checkbox"
      return 1
    elsif question.is_a? ScoredQuestion
      @question_max_score
    else
      "N/A"
    end
  end

  def average_score_for_row
    row_average_score=0.0
    actual_average_count=0.0 # New variable used to count the number reviews given
    @score_row.each do |score|
      if score.score_value.is_a? Numeric
        # puts "This is the place to change  #{score.score_value.to_f}"
        row_average_score+= score.score_value.to_f
        actual_average_count+=1 # Summing the number of reviews given
      end
    end
    ############# Function for calculating the review
    if actual_average_count.zero?
      row_average_score
    else
      row_average_score/=actual_average_count
    end
    ############ End of function
    # row_average_score /= @score_row.length.to_f # This was the previous code for calculating the review average
    row_average_score.round(2)
  end
end
