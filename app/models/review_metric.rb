class ReviewMetric < ActiveRecord::Base
  attr_accessible :id, :metric
  has_many :review_metrics_mappings
end
