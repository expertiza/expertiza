class GradingHistory < ActiveRecord::Base
  attr_protected
  belongs_to :instructor, inverse_of: :instructor_id
  belongs_to :assignment, inverse_of: :assignment_id
end