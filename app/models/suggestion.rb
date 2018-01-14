class Suggestion < ActiveRecord::Base
  validates :title, :description, presence: true
  has_many :suggestion_comments
end
