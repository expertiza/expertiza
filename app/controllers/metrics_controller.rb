class MetricsController
  def bulk_service_retrival(reviews,metric,confidence)
    if confidence
        if %w(problem suggestions sentiment emotions).include?(metric)
          reviews['reviews'].each do |review|
            output_to_append = {'confidence': rand }
            review.merge!(output_to_append)
          end
        end
    end
    reviews
  end
end