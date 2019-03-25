class ReviewCommentPasteBin < ActiveRecord::Base
  attr_accessor :review
  belongs_to :review_grade
end
