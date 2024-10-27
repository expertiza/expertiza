# represents each row of a heatgrid-table, which is represented by the vm_question_response class.
class VmQuestionResponseRow
  attr_reader :question_seq, :question_text, :question_id, :score_row, :weight
  attr_accessor :metric_hash

  def initialize(question_text, question_id, weight, question_max_score, seq)
    @question_text = question_text
    @weight = weight
    @question_id = question_id
    @question_seq = seq
    @question_max_score = question_max_score
    @score_row = []
    @metric_hash = {}
  end

  # the question max score is the max score of the questionnaire, except if the question is a true/false, in which case
  # the max score is one.
  def question_max_score
    question = Question.find(question_id)
    if question.type == 'Checkbox'
      1
    elsif question.is_a? ScoredQuestion
      @question_max_score
    else
      'N/A'
    end
  end

  def average_score_for_row
    row_average_score = 0.0
    no_of_columns = 0.0 # Counting reviews that are not null
    @score_row.each do |score|
      if score.score_value.is_a? Numeric
        no_of_columns += 1
        row_average_score += score.score_value.to_f
      end
    end
    unless no_of_columns.zero?
      row_average_score /= no_of_columns
      row_average_score.round(2)
    end
  end
end
