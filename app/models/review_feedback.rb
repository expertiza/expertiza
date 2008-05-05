class ReviewFeedback < ActiveRecord::Base
    has_many :review_scores
    belongs_to :review
    belongs_to :assignment
    belongs_to :author, :class_name => "User", :foreign_key => "author_id"
end
