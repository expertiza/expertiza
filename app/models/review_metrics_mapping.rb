class ReviewMetricsMapping < ActiveRecord::Base
  attr_accessible :id, :response, :metric, :value
  belongs_to :review_metric
  belongs_to :response
end
