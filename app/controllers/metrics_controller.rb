class MetricsController
  def bulk_service_retrival(reviews,metric,type)
    if type == 'confidence'
        if %w(problem suggestions).include?(metric)
          reviews['reviews'].each do |review|
            output_to_append = {'confidence': rand }
            review.merge!(output_to_append)
          end

        elsif %w(sentiment emotions).include?(metric)

          reviews['reviews'].each do |review|
            output_to_append = {'confidence': rand > 0.5 ? 1 : 0 }
            review.merge!(output_to_append)
          end
        end
    end
    reviews
  end
end