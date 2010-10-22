class ReviewComment < ActiveRecord::Base
  belongs_to :review_file
end
