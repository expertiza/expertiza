class Feedback < ActiveRecord::Base
  validates :user_email, :title, :presence => true
end
