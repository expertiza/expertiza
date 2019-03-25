class ReviewGrade < ActiveRecord::Base
  attr_accessor :review
  belongs_to :participant
end
