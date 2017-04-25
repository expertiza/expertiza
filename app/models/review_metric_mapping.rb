class ReviewMetricMapping < ActiveRecord::Base
  attr_accessible :id, :value, :review_metrics_id, :responses_id
  belongs_to :review_metric
  belongs_to :response
  validates :review_metrics_id, presence: true
  validates :responses_id, presence: true
  validates :value, presence: true
end