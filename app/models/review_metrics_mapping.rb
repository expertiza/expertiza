class ReviewMetricsMapping < ActiveRecord::Base
  attr_accessible :id, :response_id, :metric_id, :value
  has_many :review_metrics
  has_many :responses
end
