class ReviewComment < ActiveRecord::Base
  belongs_to :review_file
  belongs_to :user
end
