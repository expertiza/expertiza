class PasswordReset < ActiveRecord::Base
  validates :user_email, :presence => true
end
