class GradingHistory < ActiveRecord::Base
  belongs_to :instructor, foreign_key: 'instructor_id'
  belongs_to :assignment, foreign_key: 'assignment_id'
end
