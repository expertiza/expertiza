# E2383 Added for tracking histories
# This class represents the GradingHistory model in the application.
# It is used to store information about grading history for assignments.
class GradingHistory < ActiveRecord::Base
  belongs_to :instructor, inverse_of: :instructor_id
  belongs_to :assignment, inverse_of: :assignment_id
end
