class Notification < ActiveRecord::Base
  attr_accessible
  validates_presence_of :subject
  validates_presence_of :description
  validates_presence_of :expiration_date
end
