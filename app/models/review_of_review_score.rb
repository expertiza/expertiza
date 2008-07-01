class ReviewOfReviewScore < ActiveRecord::Base
  belongs_to :review_of_review
  def delete
    self.destroy
  end
end
