class Bookmark < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  has_many :bookmark_ratings
  validates_presence_of :url
  validates_presence_of :title
  validates_presence_of :description
end

