# This class represents the SubmissionGradingHistory model in the application,
# which inherits from the GradingHistory class.
# It is used to store information about the grading history specifically for submission purposes.
class SubmissionGradingHistory < GradingHistory
  attr_protected
  belongs_to :grade_receiver, class_name: 'Team', inverse_of: :grade_receiver_id
end
