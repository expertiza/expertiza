class ScoreView < ApplicationRecord
  # setting this to false so that factories can be created
  # to test the grading of weighted quiz itemnaires
  def readonly?
    false
  end

  def self.itemnaire_data(itemnaire_id, response_id)
    itemnaire_data = ScoreView.find_by_sql ["SELECT q1_max_item_score ,SUM(item_weight) as sum_of_weights,SUM(item_weight * s_score) as weighted_score FROM score_views WHERE type in('Criterion', 'Scale') AND q1_id = ? AND s_response_id = ?", itemnaire_id, response_id]
    itemnaire_data[0]
  end
end
