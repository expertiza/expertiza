class FeedbackMapping < ActiveRecord::Base
  belongs_to :review, :class_name => "Review", :foreign_key => "reviewed_object_id"
  belongs_to :reviewer, :class_name => "Participant", :foreign_key => "reviewer_id"
  belongs_to :reviewee, :class_name => "Participant", :foreign_key => "reviewee_id"
  
  def assignment
    self.review.review_mapping.assignment
  end
end
