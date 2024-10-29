class AccountRequest < ApplicationRecord
  before_save { self.email = email.downcase }
  before_save { username }
  validates :username, presence: true, length: { maximum: 50, message: 'is too long' }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  validates :email, presence: true, length: { maximum: 255, message: 'is too long' },
                    format: { with: VALID_EMAIL_REGEX, message: 'format is wrong' },
                    uniqueness: { case_sensitive: false, message: 'has already existed in Expertiza' }

  validates :name, presence: true, length: { maximum: 100, message: 'is too long' }
end
