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
    end
    output
  end
end
