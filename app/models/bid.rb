class Bid < ActiveRecord::Base
  belongs_to :topic, :class_name => 'SignUpTopic'
  belongs_to :team
end
