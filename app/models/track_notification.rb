class TrackNotification < ApplicationRecord
  # attr_accessible :notification
  validates :notification_id, presence: true
  validates :user_id, presence: true
  belongs_to :notification
  belongs_to :user
end
