class Bookmark < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
  has_many :bookmark_ratings
  validates :url, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates_format_of :url, :multiline => true, :with => /^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/

end
