# represents each row of a heatgrid-table, which is represented by the vm_question_response class.
class VmQuestionResponseRow
  def initialize(questionText, question_id, weight, question_max_score, seq, default_score=[])
    @questionText = questionText
    @weight = weight

    @question_id = question_id
    @question_seq = seq

    @question_max_score = question_max_score

    @score_row = default_score

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
    row_average_score = 0.0
    # E1787 changes
    not_null_reviews = 0.0 # variable added to makesure not null reviews are ignored
    @score_row.each do |score|
      if score.score_value.is_a? Numeric
        row_average_score += score.score_value.to_f
        not_null_reviews += 1 # Summing the number of non null reviews
      end
    end
    row_average_score /= not_null_reviews unless not_null_reviews.zero? # updates row_average_scores iff and only if, few reviews are null
    row_average_score.round(2) unless not_null_reviews.zero? # checking if there are not_null_reviews
    # returning null => displaying null, if all the reviews are null
  end
end