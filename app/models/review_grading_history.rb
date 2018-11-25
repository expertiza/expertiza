class ReviewGradingHistory < GradingHistory
  belongs_to :grade_receiver, class_name: 'Participant',foreign_key: 'grade_receiver_id'
end