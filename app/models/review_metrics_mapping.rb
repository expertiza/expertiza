class ReviewMetricsMapping < ActiveRecord::Base
  has_many :review_metrics
  has_many :responses
end
