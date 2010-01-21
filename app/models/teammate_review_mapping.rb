class TeammateReviewMapping < ActiveRecord::Base
  belongs_to :assignment, :class_name => "Assignment", :foreign_key => "reviewed_object_id"
  belongs_to :reviewer, :class_name => "Participant", :foreign_key => "reviewer_id"
  belongs_to :reviewee, :class_name => "Participant", :foreign_key => "reviewee_id"
end
