class Notification < ActiveRecord::Base
  has_many :meta_conditions
  has_one :notification_message
end
