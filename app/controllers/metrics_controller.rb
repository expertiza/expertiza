class MetricsController
  def bulk_service_retrival(reviews, metric, confidence)
    output = {'reviews' => []}
    if confidence
      if %w[problem suggestions sentiment emotions].include?(metric)
        reviews['reviews'].each do |review|
          review_with_confidence = {'id' => review['id'], 'text' => review['text'], 'confidence' => rand.to_f}
          output['reviews'] << review_with_confidence
        end
      end
    end
    puts "Reviews: #{output}"
    output
  end
end