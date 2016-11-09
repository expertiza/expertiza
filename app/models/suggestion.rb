class Suggestion < ActiveRecord::Base
  validates_presence_of :title, :description
  has_many :suggestion_comments
end
