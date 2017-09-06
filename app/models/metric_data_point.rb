class MetricDataPoint < ActiveRecord::Base
  has_one :metric
  has_one :metric_data_point_type
end
