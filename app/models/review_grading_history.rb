# This class represents the ReviewGradingHistory model in the application,
# which inherits from the GradingHistory class.
# It is used to store information about the grading history specifically for review purposes.
class ReviewGradingHistory < GradingHistory
  attr_protected
  belongs_to :grade_receiver, class_name: 'Participant', inverse_of: :grade_receiver_id
end
