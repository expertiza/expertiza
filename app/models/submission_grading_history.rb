class SubmissionGradingHistory < GradingHistory
  attr_protected
  belongs_to :graded_member, class_name: 'Team'
end