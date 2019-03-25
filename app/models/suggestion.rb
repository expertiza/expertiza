class Suggestion < ActiveRecord::Base
  validates :title, :description, presence: true
  has_many :suggestion_comments
  attr_accessible :assignment_id, :title, :description, :status, :unityID, :signup_preference
end
