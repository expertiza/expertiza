class TrackNotification < ActiveRecord::Base
  attr_accessible :id, :notification, :user_id
  validates :notification, presence: true
  validates :user_id, presence: true
end
