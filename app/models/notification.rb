class Notification < ActiveRecord::Base
  attr_accessible :id, :subject, :description, :expiration_date, :active_flag
  validates :subject, presence: true
  validates :description, presence: true
  validates :expiration_date, presence: true
end
