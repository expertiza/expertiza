class ReviewCommentPasteBin < ApplicationRecord
  # attr_accessible :title, :review_comment
  belongs_to :review_grade
end
