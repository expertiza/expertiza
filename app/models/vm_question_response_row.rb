# represents each row of a heatgrid-table, which is represented by the vm_question_response class.
class VmQuestionResponseRow
  attr_reader :question_seq, :question_text, :question_id, :score_row, :weight
  attr_accessor :countofcomments

  def initialize(question_text, question_id, weight, question_max_score, seq)
    @question_text = question_text
    @weight = weight
    @question_id = question_id
    @question_seq = seq
    @question_max_score = question_max_score
    @score_row = []
    @countofcomments = 0
  end

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
    # Changes By Rahul Sethi
    # Making global so that new function can access them
    @no_of_columns = 0.0 # Counting reviews that are not null
    @self_review_score_of_row = @score_row[-1].score_value
    @score_row.each do |score|
      if score.score_value.is_a? Numeric
        @no_of_columns += 1
        row_average_score += score.score_value.to_f
      end
    end
    return unless @no_of_columns.zero?
    row_average_score /= @no_of_columns
    row_average_score.round(2)
    # Changes End
  end

  def new_derived_score
    @self_review_score = ((average_score_for_row * @no_of_columns) - @self_review_score_of_row) / (@no_of_columns - 1)
    @final_score_after = "Self Review Not Enabled"
    return unless @self_review_score.nan?
    deviated_score = (100 - (@self_review_score_of_row - @self_review_score).abs) / 100;
    @final_score_after = deviated_score * @self_review_score
    @final_score_after.round(2)
  end
end
