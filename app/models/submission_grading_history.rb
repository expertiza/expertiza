class SubmissionGradingHistory < GradingHistory
  belongs_to :grade_receiver, class_name: 'Team',foreign_key: 'grade_receiver_id'
end
