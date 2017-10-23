class ReviewCommentPasteBin < ActiveRecord::Base
  belongs_to :review_grade

  attr_accessible
end
