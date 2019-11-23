class ReviewBid < ActiveRecord::Base
  belongs_to :topic, class_name: 'SignUpTopic'
  belongs_to :participant, class_name: 'Participant'
end
