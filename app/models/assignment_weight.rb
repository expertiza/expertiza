class AssignmentWeight < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :sign_up_topic
  validates_presence_of :assignment_id
  validates_presence_of :weight
  validates_presence_of :topic_id
end
