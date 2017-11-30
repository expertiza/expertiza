class MetricDataPointType < ActiveRecord::Base
  enum source: [ :github, :trello ]
  enum dimension: [ :label, :x, :y ]
end
