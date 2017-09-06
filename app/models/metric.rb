class Metric < ActiveRecord::Base
  has_one :metric
  has_one :team
  has_many :metric_data_point, dependent: :destroy
end
