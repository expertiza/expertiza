class GradingHistory < ActiveRecord::Base
  attr_accessible
  belongs_to :instructor, inverse_of: :instructor_id
  belongs_to :assignment, inverse_of: :assignment_id
  validates :instructor_id, presence: true
  validates :assignment_id, presence: true
  validates :grading_type, presence: true
  validates :grade_receiver_id, presence: true
  validates :graded_at, presence: true
end
