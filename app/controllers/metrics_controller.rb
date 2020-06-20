class MetricsController
  def confidence_metric(reviews)
    reviews[:reviews].each do |review|
      output_to_append = {Sentiment: rand,
                          Suggestions: rand,
                          Emotion: rand,
                          Problem: rand }
      review.merge!(Confidence: output_to_append)
    end
    reviews
  end
end