class ReviewMetric < ActiveRecord::Base
  attr_accessible :id, :metric
  has_many :review_metric_mappings
  validates :metric, presence: true
end
