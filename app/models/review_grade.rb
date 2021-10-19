class ReviewGrade < ActiveRecord::Base
  attr_accessible :grade_for_reviewer, :comment_for_reviewer, :review_graded_at, :participant_id
  belongs_to :participant
end
