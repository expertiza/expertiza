# represents each row of a heatgrid-table, which is represented by the vm_question_response class.
class VmQuestionResponseRow
  attr_reader :question_seq, :question_text, :question_id, :score_row, :weight
  attr_accessor :countofcomments

  def initialize(question_data)
    @question_text = question_data[:text]
    @question_id = question_data[:id]
    @weight = question_data[:weight]
    @question_max_score = question_data[:max_score]
    @question_seq = question_data[:seq]
    @score_row = []
    @countofcomments = 0
  end

  # the question max score is the max score of the questionnaire, except if the question is a true/false, in which case
  # the max score is one.
  def question_max_score
    question = Question.find(self.question_id)
    return 1 if question.type == 'Checkbox'
    return @question_max_score if question.is_a? ScoredQuestion
    'N/A'
  end

  def average_score_for_row
    row_average_score = 0.0
    count_columns = 0.0 # Counting reviews that are not null
    @score_row.each do |score|
      if score.score_value.is_a? Numeric
        count_columns += 1
        row_average_score += score.score_value.to_f
      end
    end
    # Return if none of the score in the score row is Numeric
    return if count_columns.zero?
    # Otherwise, calculate average score for a row
    row_average_score /= count_columns
    row_average_score.round(2)
  end
end
