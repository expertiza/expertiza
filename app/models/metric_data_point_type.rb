class MetricDataPointType < ActiveRecord::Base
  enum source: [ :github, :trello, :wiki ]
  enum dimension: [ :label, :x, :y ]
end
