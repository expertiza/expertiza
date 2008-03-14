class ReviewFeedback < ActiveRecord::Base
    has_many :review_scores
end
