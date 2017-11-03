class MetricDataPointType < ActiveRecord::Base
  enum dimension: [ :label, :x, :y ]
end
