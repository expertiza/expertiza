class Bid < ActiveRecord::Base
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :user
  attr_accessible :topic_id, :team_id, :created_id, :updated_at, :priority
end
