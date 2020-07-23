class MetricsController
  def bulk_service_retrival(reviews, metric, confidence)
    output = {'reviews' => []}
    if confidence
      if %w[problem suggestions].include?(metric)
        reviews['reviews'].each do |review|
          review_with_confidence = {'id' => review['id'], 'text' => review['text'], 'confidence' => rand}
          output['reviews'] << review_with_confidence
        end
      elsif %w[sentiment emotions].include?(metric)
        reviews['reviews'].each do |review|
          review_with_confidence = {'id' => review['id'], 'text' => review['text'], 'confidence' => rand > 0.5 ? 1 : 0}
          output['reviews'] << review_with_confidence
        end
      end
    else
      if metric == 'problem'
        reviews['reviews'].each do |review|
          review_with_value = {'id' => review['id'], 'text' => review['text'], 'problems' => rand > 0.5 ? 'Present' : 'Absent'}
          output['reviews'] << review_with_value
        end
      elsif metric == 'suggestions'
        reviews['reviews'].each do |review|
          review_with_value = {'id' => review['id'], 'text' => review['text'], 'suggestions' => rand > 0.5 ? 'Present' : 'Absent'}
          output['reviews'] << review_with_value
        end
      elsif metric == 'emotions'
        reviews['reviews'].each do |review|
          review_with_value = {'id' => review['id'], 'text' => review['text'], 'Praise' => rand > 0.5 ? 'Low' : 'None'}
          output['reviews'] << review_with_value
        end
      elsif metric == 'sentiment'
        reviews['reviews'].each do |review|
          review_with_value = {'id' => review['id'], 'text' => review['text'], 'sentiment_tone' => rand > 0.5 ? 'Positive' : 'Negative'}
          output['reviews'] << review_with_value
        end
      end
    end
    output
  end
end
