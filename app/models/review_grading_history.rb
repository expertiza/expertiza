class ReviewGradingHistory < GradingHistory
  attr_protected
  belongs_to :grade_receiver, class_name: 'Participant', inverse_of: :grade_receiver_id
end