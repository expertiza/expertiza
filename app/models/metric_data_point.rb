class MetricDataPoint < ActiveRecord::Base
  has_one :metric
  belongs_to :metric_data_point_type
end
