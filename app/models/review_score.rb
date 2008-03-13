class ReviewScore < ActiveRecord::Base
  belongs_to :review
  belongs_to :question
end
