class SimilarAssignment < ActiveRecord::Base
  has_many :assignments, dependent: :destroy
end
