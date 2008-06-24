class ReviewOfReviewScore < ActiveRecord::Base
  def delete
    self.destroy
  end
end
