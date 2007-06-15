class Review < ActiveRecord::Base
  has_many :review_feedbacks
  has_many :review_scores
end
