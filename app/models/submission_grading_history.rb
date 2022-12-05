class SubmissionGradingHistory < GradingHistory
  belongs_to :grade_receiver, class_name: 'Team', inverse_of: :grade_receiver_id
end