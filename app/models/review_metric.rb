class ReviewMetric < ActiveRecord::Base
  has_many :review_metrics_mappings
end
