class ReviewGrade < ActiveRecord::Base
  belongs_to :participant
  attr_accessible
end
