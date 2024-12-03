module ScoreCalculationHelper
  def weighted_score(scores, weights)
    total_weight = weights.sum
    # Multiply each score by its weight, then divide by the total weight
    weighted_scores = scores.zip(weights).map { |score, weight| score * weight }
    weighted_scores.sum.to_f / total_weight.to_f
  end

  def apply_penalty(score, penalty)
    raise ArgumentError, 'Penalty cannot be negative' if penalty.negative?
    score - (score * penalty / 100.0)
  end
end