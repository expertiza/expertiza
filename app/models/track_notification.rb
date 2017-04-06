class TrackNotification < ActiveRecord::Base
  attr_accessible :notification
  validates :notification, presence: true
  validates :user_id, presence: true
end
