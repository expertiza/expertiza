class Notification < ActiveRecord::Base
  attr_accessible :course_id, :subject, :description, :expiration_date, :active_flag
  validates :subject, presence: true
  validates :description, presence: true
  validates :expiration_date, presence: true
  belongs_to :course
  has_many :track_notifications, dependent: :destroy
end
