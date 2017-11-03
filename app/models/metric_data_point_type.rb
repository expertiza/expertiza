class MetricDataPointType < ActiveRecord::Base
  enum source: [ :github ]
  enum dimension: [ :label, :x, :y ]
end
