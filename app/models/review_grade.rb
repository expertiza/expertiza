class ReviewGrade < ActiveRecord::Base
  belongs_to :participant
  attr_accessible :participant_id, :grade_for_reviewer, :comment_for_reviewer, :review_graded_at, :reviewer_id
end
