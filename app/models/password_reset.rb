class PasswordReset < ApplicationRecord
  validates :user_email, presence: true
  # attr_accessible :user_email, :token
  def self.save_token(user, token)
    password_reset = PasswordReset.find_by(user_email: user.email)
    if password_reset
      password_reset.token = Digest::SHA1.hexdigest(token)
      password_reset.save!
    else
      PasswordReset.create(user_email: user.email, token: Digest::SHA1.hexdigest(token))
    end
  end
end
