class ReviewGrade < ActiveRecord::Base
<<<<<<< HEAD
  attr_accessible :grade_for_reviewer, :comment_for_reviewer, :review_graded_at
=======
  attr_accessible :grade_for_reviewer, :comment_for_reviewer, :review_graded_at, :participant_id
>>>>>>> master
  belongs_to :participant
end
