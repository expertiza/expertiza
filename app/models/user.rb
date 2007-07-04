require 'digest/sha1'

class User < ActiveRecord::Base
  has_and_belongs_to_many :courses
  has_many :participants
  has_many :assignments, :through => :participants
  validates_presence_of :name
  validates_uniqueness_of :name

  attr_accessor :clear_password
  attr_accessor :confirm_password
  
  def list_mine(object_type, user_id)
    object_type.find(:all, :conditions => ["instructor_id = ?", user_id])
  end

  def role
    if self.role_id
      @role ||= Role.find(self.role_id)
    end
    return @role
  end
    
  def before_save
    if self.clear_password  # Only update the password if it has been changed
      self.password_salt = self.object_id.to_s + rand.to_s
      self.password = Digest::SHA1.hexdigest(self.password_salt +
                                             self.clear_password)
    end
  end

  def after_save
    self.clear_password = nil
  end

  def check_password(clear_password)
    self.password == Digest::SHA1.hexdigest(self.password_salt.to_s +
                                                 clear_password)
  end
end
