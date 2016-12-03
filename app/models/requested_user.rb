class RequestedUser < ActiveRecord::Base

before_save { self.email = email.downcase}
before_save { self.name }
validates :name, presence: true, length: { maximum: 50 }
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

validates :fullname, presence: true, length: { maximum: 100 }  

end
