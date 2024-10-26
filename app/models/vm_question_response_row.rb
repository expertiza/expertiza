# represents each row of a heatgrid-table, which is represented by the vm_item_response class.
class VmQuestionResponseRow
  attr_reader :item_seq, :item_text, :item_id, :score_row, :weight
  attr_accessor :metric_hash

  def initialize(item_text, item_id, weight, item_max_score, seq)
    @item_text = item_text
    @weight = weight
    @item_id = item_id
    @item_seq = seq
    @item_max_score = item_max_score
    @score_row = []
    @metric_hash = {}
  end

  # the item max score is the max score of the itemnaire, except if the item is a true/false, in which case
  # the max score is one.
  def item_max_score
    item = Question.find(item_id)
    if item.type == 'Checkbox'
      1
    elsif item.is_a? ScoredQuestion
      @item_max_score
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
