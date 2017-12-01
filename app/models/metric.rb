class Metric < ActiveRecord::Base
  enum source: [ :github, :trello, :wiki ]
  belongs_to :team
  belongs_to :assignment
  has_many :metric_data_points, dependent: :destroy, foreign_key: 'metric_id'
end
