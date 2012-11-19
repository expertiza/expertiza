class Bid < ActiveRecord::Base
  belongs_to :topic, :class_name => 'SignUpTopic'
  belongs_to :team
  attr_accessible :topic_id, :team_id
end
