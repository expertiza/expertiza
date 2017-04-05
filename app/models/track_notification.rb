class TrackNotification < ActiveRecord::Base

  validates :notification, presence: true
  validates :user_id, presence: true
end
