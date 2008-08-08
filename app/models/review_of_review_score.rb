class ReviewOfReviewScore < ActiveRecord::Base
  belongs_to :review_of_review
  belongs_to :question
  def delete
    self.destroy
  end
end
