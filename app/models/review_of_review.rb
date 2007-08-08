class ReviewOfReview < ActiveRecord::Base
    has_many :review_of_review_scores
end
