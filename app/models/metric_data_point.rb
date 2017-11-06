class MetricDataPoint < ActiveRecord::Base
  belongs_to :metric_data_point_type, foreign_key: "metric_data_point_type_id"
  belongs_to :metric, foreign_key: "metric_id"
end
