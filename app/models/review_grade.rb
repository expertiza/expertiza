class ReviewGrade < ActiveRecord::Base
<<<<<<< HEAD
  attr_accessible :grade_for_reviewer, :comment_for_reviewer, :review_graded_at
=======
  attr_accessor :review
>>>>>>> Rahul and Shraddha Code Climate Fixes
  belongs_to :participant
end
