class ReviewCommentPasteBin < ActiveRecord::Base
<<<<<<< HEAD
  attr_accessible :title, :review_comment
=======
  attr_accessor :review
>>>>>>> Rahul and Shraddha Code Climate Fixes
  belongs_to :review_grade
end
