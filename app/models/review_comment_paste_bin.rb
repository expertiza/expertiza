class ReviewCommentPasteBin < ActiveRecord::Base
<<<<<<< HEAD
<<<<<<< HEAD
  attr_accessible :title, :review_comment
=======
  attr_accessor :review
>>>>>>> Rahul and Shraddha Code Climate Fixes
=======
  attr_accessible :title, :review_comment
>>>>>>> Final changes with all tests passed
  belongs_to :review_grade
end
