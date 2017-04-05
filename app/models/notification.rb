class Notification < ActiveRecord::Base

  validates :subject, presence: true
  validates :description, presence: true
  validates :expiration_date, presence: true
end
