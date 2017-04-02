class Notification < ActiveRecord::Base
  attr_accessible
  validates :subject, presence: true
  validates :description, presence: true
  validates :expiration_date, presence: true
end
