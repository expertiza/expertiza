class CodeReview < ActiveRecord::Base
  has_many :participants
  has_many :review_files
end
