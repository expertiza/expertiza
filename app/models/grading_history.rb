class GradingHistory < ActiveRecord::Base
  attr_accessible :instructor_id, :assignment_id,
                  :grading_type, :grade_receiver_id, :grade, :comment
  belongs_to :instructor, inverse_of: :instructor_id
  belongs_to :assignment, inverse_of: :assignment_id
end
