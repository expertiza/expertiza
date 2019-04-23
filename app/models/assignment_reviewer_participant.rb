class AssignmentReviewerParticipant < ActiveRecord::Base
  belongs_to  :assignment_participant, class_name: 'AssignmentParticipant', foreign_key: 'id'
end
