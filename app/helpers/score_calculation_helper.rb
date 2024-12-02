module ScoreCalculationHelper
  def weighted_score(scores, weights)
    total_weight = weights.sum
    # Multiply each score by its weight, then divide by the total weight
    weighted_scores = scores.zip(weights).map { |score, weight| score * weight }
    weighted_scores.sum / total_weight
  end

  def apply_penalty(score, penalty)
    score - (score * penalty / 100.0)
  end
end