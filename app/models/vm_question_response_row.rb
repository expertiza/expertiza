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

    @self_review_score = -1
  end

  attr_reader :countofcomments

  attr_reader :question_seq

  attr_writer :countofcomments

  attr_reader :questionText

  attr_reader :question_id

  attr_reader :score_row

  attr_reader :weight

  attr_accessor :self_review_score

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
    @score_row.each do |score|
      if score.score_value.is_a? Numeric
        row_average_score += score.score_value.to_f
      end
    end
    row_average_score /= @score_row.length.to_f
    row_average_score.round(2)
  end

  # it calculates the difference between the self review score and average of all reviews.
  def weighted_diff_for_row
    weighted_average_score =  average_score_for_row / question_max_score
    weighted_self_review_score = self_review_score.score_value / question_max_score
    result = weighted_average_score - weighted_self_review_score 
    result = result > 0 ? result : -result
  end



end
