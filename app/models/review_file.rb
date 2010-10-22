class ReviewFile < ActiveRecord::Base
  belongs_to :code_review
  has_many :review_comments
end
