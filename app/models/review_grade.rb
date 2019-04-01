class ReviewGrade < ActiveRecord::Base
<<<<<<< HEAD
<<<<<<< HEAD
  attr_accessible :grade_for_reviewer, :comment_for_reviewer, :review_graded_at
=======
  attr_accessor :review
>>>>>>> Rahul and Shraddha Code Climate Fixes
=======
  attr_accessible :grade_for_reviewer, :comment_for_reviewer, :review_graded_at
>>>>>>> Final changes with all tests passed
  belongs_to :participant
end
